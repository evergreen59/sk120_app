import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/core/errors/app_error.dart';
import 'package:xy_sk120_control/core/result/result.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/protocol/modbus_client.dart';
import 'package:xy_sk120_control/domain/protocol/modbus_frame.dart';
import 'package:xy_sk120_control/domain/repositories/ble_transport.dart';
import 'package:xy_sk120_control/domain/services/real_power_device.dart';

void main() {
  test(
    'reads status as 32 plus 4 registers and merges decoded fields',
    () async {
      final transport = _DeviceTransport();
      transport.registers[15] = 1;
      transport.registers[16] = 7;
      transport.registers[17] = 1;
      transport.registers[18] = 0;
      transport.registers[20] = 5;
      transport.registers[25] = 5;
      final device = _deviceFor(transport);
      await device.connect();

      final result = await device.readStatus();

      expect(result.isSuccess, isTrue);
      expect(transport.readRequests, [
        (start: 0, quantity: 32),
        (start: 32, quantity: 4),
      ]);
      expect(result.value!.keyLocked, isTrue);
      expect(result.value!.backlightLevel, 5);
      expect(result.value!.protectionStatus, ProtectionStatus.overTemperature);
      expect(result.value!.protectionRaw, 7);
      expect(result.value!.cvccState, CvccState.cc);
      expect(result.value!.outputState, OutputState.off);
      expect(result.value!.baudRate, DeviceBaudRate.baud57600);
      expect(result.value!.baudRateRaw, 5);
      await device.dispose();
      await transport.dispose();
    },
  );

  test('preserves unknown protection and baud codes for diagnostics', () async {
    final transport = _DeviceTransport();
    transport.registers[16] = 99;
    transport.registers[18] = 1;
    transport.registers[25] = 99;
    final device = _deviceFor(transport);
    await device.connect();

    final status = (await device.readStatus()).value!;

    expect(status.protectionStatus, isNull);
    expect(status.protectionRaw, 99);
    expect(status.keyLocked, isFalse);
    expect(status.cvccState, CvccState.cv);
    expect(status.outputState, OutputState.on);
    expect(status.baudRate, isNull);
    expect(status.baudRateRaw, 99);
    await device.dispose();
    await transport.dispose();
  });

  test(
    'does not publish a partial status when the second read fails',
    () async {
      final transport = _DeviceTransport(failSecondRead: true);
      transport.registers[0] = 2400;
      final device = _deviceFor(transport);
      await device.connect();
      final emitted = <DeviceStatus>[];
      final subscription = device.statusStream.listen(emitted.add);

      final result = await device.readStatus();

      expect(result.isFailure, isTrue);
      expect(device.status.voltageSet, isNull);
      expect(emitted, isEmpty);
      await subscription.cancel();
      await device.dispose();
      await transport.dispose();
    },
  );

  test('M0 and M9 activation only write EXTRACT-M before refreshing', () async {
    final transport = _DeviceTransport();
    final device = _deviceFor(transport);
    await device.connect();
    await device.readStatus();
    transport.writes.clear();

    expect((await device.activateDataGroup(0)).isSuccess, isTrue);
    expect((await device.activateDataGroup(9)).isSuccess, isTrue);

    final calls = transport.writes.where((frame) => frame[1] == 0x06).toList();
    expect(calls, hasLength(2));
    expect(calls[0].sublist(0, 6), [1, 6, 0, 0x1D, 0, 0]);
    expect(calls[1].sublist(0, 6), [1, 6, 0, 0x1D, 0, 9]);
    expect(transport.writes.where((frame) => frame[1] == 0x10), isEmpty);
    expect((await device.activateDataGroup(-1)).isFailure, isTrue);
    expect((await device.activateDataGroup(10)).isFailure, isTrue);

    transport.registers[18] = 1;
    await device.readStatus();
    transport.writes.clear();
    expect((await device.activateDataGroup(0)).isFailure, isTrue);
    expect(transport.writes, isEmpty);

    transport.registers[18] = 0;
    await device.readStatus();
    transport.writes.clear();
    expect(
      (await device.writeDataGroup(
        const DataGroup(index: 0, voltageSet: 12, currentSet: 1.25),
      )).isSuccess,
      isTrue,
    );
    expect(transport.writes, hasLength(1));
    expect(transport.writes.single.sublist(0, 7), [
      1,
      0x10,
      0,
      0x50,
      0,
      14,
      28,
    ]);
    await device.dispose();
    await transport.dispose();
  });

  test(
    'writes lock, backlight and every baud code to documented registers',
    () async {
      final transport = _DeviceTransport();
      final device = _deviceFor(transport);
      await device.connect();

      await device.setKeyLock(true);
      await device.setBacklight(5);
      for (final rate in DeviceBaudRate.values) {
        await device.setBaudRate(rate);
      }

      final writes = transport.writes
          .where((frame) => frame[1] == 0x06)
          .toList();
      expect(writes[0].sublist(2, 6), [0, 0x0F, 0, 1]);
      expect(writes[1].sublist(2, 6), [0, 0x14, 0, 5]);
      expect(
        writes.skip(2).map((frame) => frame[5]),
        DeviceBaudRate.values.map((rate) => rate.code),
      );
      expect((await device.setBacklight(-1)).isFailure, isTrue);
      expect((await device.setBacklight(6)).isFailure, isTrue);
      await device.dispose();
      await transport.dispose();
    },
  );

  test('covers command setters, groups and validation boundaries', () async {
    final transport = _DeviceTransport();
    final device = _deviceFor(transport);
    await device.connect();
    await device.readStatus();

    expect((await device.setVoltage(12)).isSuccess, isTrue);
    expect(
      (await device.setVoltage(36.01)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect((await device.setCurrent(1.25)).isSuccess, isTrue);
    expect(
      (await device.setCurrent(5.01)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect((await device.setOutput(true)).isSuccess, isTrue);
    expect((await device.setBuzzer(false)).isSuccess, isTrue);
    expect((await device.setSleepMinutes(65535)).isSuccess, isTrue);
    expect(
      (await device.setSleepMinutes(65536)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect((await device.setSlaveAddress(42)).isSuccess, isTrue);
    expect(device.status.slaveAddress, 42);
    expect(
      (await device.setSlaveAddress(0)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect(
      (await device.setMppt(enabled: true, coefficient: 17)).isSuccess,
      isTrue,
    );
    expect((await device.setMppt(enabled: false)).isSuccess, isTrue);
    expect(
      (await device.setConstantPower(enabled: true, watts: 40)).isSuccess,
      isTrue,
    );
    expect(
      (await device.setConstantPower(enabled: true, watts: -1)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect(
      (await device.setConstantPower(enabled: true, watts: 121)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect(
      (await device.setConstantPower(
        enabled: true,
        watts: double.nan,
      )).error?.code,
      ErrorCode.invalidRegisterValue,
    );

    transport.registers[0x50] = 1850;
    transport.registers[0x51] = 2250;
    transport.registers[0x52] = 900;
    transport.registers[0x53] = 3000;
    transport.registers[0x54] = 1250;
    transport.registers[0x55] = 200;
    transport.registers[0x56] = 1;
    transport.registers[0x57] = 2;
    transport.registers[0x58] = 0x1234;
    transport.registers[0x59] = 0x5678;
    transport.registers[0x5A] = 0x2345;
    transport.registers[0x5B] = 0x6789;
    transport.registers[0x5C] = 70;
    transport.registers[0x5D] = 1;
    transport.registers[0x5E] = 80;
    final group = await device.readDataGroup(0);
    expect(group.isSuccess, isTrue);
    expect(group.value?.voltageSet, 18.5);
    expect(group.value?.currentSet, 2.25);
    expect(group.value?.maxOutputAh, 0x56781234);
    expect(group.value?.maxOutputWh, 0x67892345);
    expect(
      (await device.readDataGroup(-1)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect(
      (await device.readDataGroup(10)).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    expect(
      (await device.writeDataGroup(const DataGroup(index: 10))).error?.code,
      ErrorCode.invalidRegisterValue,
    );
    await device.setOutput(false);
    expect(
      (await device.writeDataGroup(
        const DataGroup(index: 0, voltageSet: 18.5, currentSet: 2.25),
      )).isSuccess,
      isTrue,
    );
    await device.dispose();
    await transport.dispose();
  });

  test(
    'connect reports failures at each BLE setup stage and read length errors',
    () async {
      final transport = _DeviceTransport(failConnect: true);
      final device = _deviceFor(transport);
      expect((await device.connect()).isFailure, isTrue);
      expect(device.status.connectionState, DeviceConnectionState.error);
      await device.dispose();
      await transport.dispose();

      final discoveryTransport = _DeviceTransport(failDiscover: true);
      final discoveryDevice = _deviceFor(discoveryTransport);
      expect((await discoveryDevice.connect()).isFailure, isTrue);
      await discoveryDevice.dispose();
      await discoveryTransport.dispose();

      final subscribeTransport = _DeviceTransport(failSubscribe: true);
      final subscribeDevice = _deviceFor(subscribeTransport);
      expect((await subscribeDevice.connect()).isFailure, isTrue);
      await subscribeDevice.dispose();
      await subscribeTransport.dispose();

      final shortTransport = _DeviceTransport(shortSecondRead: true);
      final shortDevice = _deviceFor(shortTransport);
      await shortDevice.connect();
      final result = await shortDevice.readStatus();
      expect(result.error?.code, ErrorCode.modbusException);
      await shortDevice.dispose();
      await shortTransport.dispose();
    },
  );
}

RealPowerDevice _deviceFor(_DeviceTransport transport) => RealPowerDevice(
  transport: transport,
  client: ModbusClient(
    transport: transport,
    timeout: const Duration(milliseconds: 20),
    readRetries: 0,
  ),
);

class _DeviceTransport implements BleTransport {
  _DeviceTransport({
    this.failSecondRead = false,
    this.failConnect = false,
    this.failDiscover = false,
    this.failSubscribe = false,
    this.shortSecondRead = false,
  }) {
    registers[0] = 1200;
    registers[1] = 1250;
    registers[5] = 2410;
    registers[18] = 0;
    registers[24] = 1;
    registers[25] = 6;
  }

  final bool failSecondRead;
  final bool failConnect;
  final bool failDiscover;
  final bool failSubscribe;
  final bool shortSecondRead;
  final List<int> registers = List.filled(0x100, 0);
  final List<List<int>> writes = [];
  final List<({int start, int quantity})> readRequests = [];
  final StreamController<List<int>> _incoming =
      StreamController<List<int>>.broadcast();
  final StreamController<DeviceConnectionState> _states =
      StreamController<DeviceConnectionState>.broadcast();

  @override
  Stream<List<int>> get incomingBytes => _incoming.stream;

  @override
  Stream<DeviceConnectionState> get connectionStates => _states.stream;

  @override
  Stream<BleDeviceInfo> scan() => const Stream.empty();

  @override
  Future<Result<void>> stopScan() async => const Success(null);

  @override
  Future<Result<void>> connect(String deviceId) async => failConnect
      ? const Failure(AppError(code: ErrorCode.bleError, message: 'connect'))
      : const Success(null);

  @override
  Future<Result<void>> reconnect(String deviceId) async => const Success(null);

  @override
  Future<Result<void>> disconnect() async => const Success(null);

  @override
  Future<Result<void>> discoverServices() async => failDiscover
      ? const Failure(AppError(code: ErrorCode.bleError, message: 'discover'))
      : const Success(null);

  @override
  Future<Result<void>> subscribe() async => failSubscribe
      ? const Failure(AppError(code: ErrorCode.bleError, message: 'subscribe'))
      : const Success(null);

  @override
  Future<Result<void>> writeFrame(List<int> bytes) async {
    writes.add(bytes);
    final function = bytes[1];
    if (function == 0x03) {
      final start = (bytes[2] << 8) | bytes[3];
      final quantity = (bytes[4] << 8) | bytes[5];
      readRequests.add((start: start, quantity: quantity));
      if (failSecondRead && start == 32) return const Success(null);
      final end = shortSecondRead && start == 32
          ? start + quantity - 1
          : start + quantity;
      final values = registers.sublist(start, end);
      final payload = <int>[bytes[0], 3, values.length * 2];
      for (final value in values) {
        payload.addAll([(value >> 8) & 0xFF, value & 0xFF]);
      }
      scheduleMicrotask(() => _incoming.add(withModbusCrc(payload)));
    } else if (function == 0x06 || function == 0x10) {
      scheduleMicrotask(
        () => _incoming.add(withModbusCrc(bytes.sublist(0, 6))),
      );
    }
    return const Success(null);
  }

  Future<void> dispose() async {
    await _incoming.close();
    await _states.close();
  }
}
