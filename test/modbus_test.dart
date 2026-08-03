import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/core/result/result.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/protocol/modbus_client.dart';
import 'package:xy_sk120_control/domain/protocol/modbus_frame.dart';
import 'package:xy_sk120_control/domain/protocol/modbus_request_queue.dart';
import 'package:xy_sk120_control/domain/repositories/ble_transport.dart';

void main() {
  group('Modbus RTU frames', () {
    test('calculates the standard CRC vector and sends low byte first', () {
      final payload = [0x01, 0x03, 0x00, 0x00, 0x00, 0x0A];
      expect(modbusCrc16(payload), 0xCDC5);
      expect(withModbusCrc(payload), [
        0x01,
        0x03,
        0x00,
        0x00,
        0x00,
        0x0A,
        0xC5,
        0xCD,
      ]);
    });

    test('builds read, single write and multiple write requests', () {
      expect(
        ModbusRequest.readRegisters(
          slaveAddress: 1,
          startAddress: 2,
          quantity: 5,
        ).toBytes().sublist(0, 6),
        [1, 3, 0, 2, 0, 5],
      );
      expect(
        ModbusRequest.writeRegister(
          slaveAddress: 1,
          address: 0x12,
          value: 0x3456,
        ).toBytes().sublist(0, 6),
        [1, 6, 0, 0x12, 0x34, 0x56],
      );
      final request = ModbusRequest.writeRegisters(
        slaveAddress: 1,
        startAddress: 0x50,
        values: [1, 2, 3],
      );
      expect(request.toBytes().sublist(0, 11), [
        1,
        0x10,
        0,
        0x50,
        0,
        3,
        6,
        0,
        1,
        0,
        2,
      ]);
      expect(request.toBytes().length, 15);
    });

    test('reassembles split and concatenated responses', () {
      final first = withModbusCrc([1, 3, 4, 0, 12, 0, 125]);
      final second = withModbusCrc([1, 3, 2, 0, 7]);
      final parser = ModbusStreamParser();
      expect(
        parser.add(first.sublist(0, 4), expectedSlave: 1, expectedFunction: 3),
        isEmpty,
      );
      final responses = parser.add(
        [...first.sublist(4), ...second],
        expectedSlave: 1,
        expectedFunction: 3,
      );
      expect(responses, hasLength(2));
      expect(responses.first.registers, [12, 125]);
      expect(responses.last.registers, [7]);
    });

    test('parses exception responses', () {
      final response = ModbusResponse.parse(withModbusCrc([1, 0x83, 2]));
      expect(response.isException, isTrue);
      expect(response.exceptionCode, 2);
    });

    test('rejects a bad CRC', () {
      expect(
        () => ModbusResponse.parse([1, 3, 2, 0, 1, 0, 0]),
        throwsA(isA<ModbusProtocolException>()),
      );
    });
  });

  group('ModbusRequestQueue', () {
    test('serializes operations even when the first one is delayed', () async {
      final queue = ModbusRequestQueue();
      final events = <String>[];
      final first = queue.enqueue(() async {
        events.add('first-start');
        await Future<void>.delayed(const Duration(milliseconds: 15));
        events.add('first-end');
        return 1;
      });
      final second = queue.enqueue(() async {
        events.add('second-start');
        return 2;
      });
      expect(await first, 1);
      expect(await second, 2);
      expect(events, ['first-start', 'first-end', 'second-start']);
    });
  });

  group('ModbusClient', () {
    test('does not retry writes and returns a timeout', () async {
      final transport = _TestTransport();
      final client = ModbusClient(
        transport: transport,
        timeout: const Duration(milliseconds: 10),
        readRetries: 2,
      );
      final result = await client.writeRegister(0, 1);
      expect(result.isFailure, isTrue);
      expect(result.error?.code.name, 'modbusTimeout');
      expect(transport.writes, hasLength(1));
      await transport.dispose();
    });

    test('retries reads only when the response is missing', () async {
      final transport = _TestTransport(respond: true);
      final client = ModbusClient(
        transport: transport,
        timeout: const Duration(milliseconds: 20),
        readRetries: 1,
      );
      final result = await client.readRegisters(0, 2);
      expect(result.isSuccess, isTrue);
      expect(result.value, [12, 125]);
      expect(transport.writes, hasLength(1));
      await transport.dispose();
    });
  });
}

class _TestTransport implements BleTransport {
  _TestTransport({this.respond = false});

  final bool respond;
  final StreamController<List<int>> _incoming =
      StreamController<List<int>>.broadcast();
  final StreamController<DeviceConnectionState> _states =
      StreamController<DeviceConnectionState>.broadcast();
  final List<List<int>> writes = [];

  @override
  Stream<List<int>> get incomingBytes => _incoming.stream;

  @override
  Stream<DeviceConnectionState> get connectionStates => _states.stream;

  @override
  Stream<BleDeviceInfo> scan() => const Stream.empty();

  @override
  Future<Result<void>> stopScan() async => const Success(null);

  @override
  Future<Result<void>> connect(String deviceId) async => const Success(null);

  @override
  Future<Result<void>> reconnect(String deviceId) async => const Success(null);

  @override
  Future<Result<void>> disconnect() async => const Success(null);

  @override
  Future<Result<void>> discoverServices() async => const Success(null);

  @override
  Future<Result<void>> subscribe() async => const Success(null);

  @override
  Future<Result<void>> writeFrame(List<int> bytes) async {
    writes.add(bytes);
    if (respond && bytes[1] == 0x03) {
      scheduleMicrotask(
        () => _incoming.add(withModbusCrc([1, 3, 4, 0, 12, 0, 125])),
      );
    }
    return const Success(null);
  }

  Future<void> dispose() async {
    await _incoming.close();
    await _states.close();
  }
}
