import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:xy_sk120_control/data/transport/universal_ble_transport.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';

void main() {
  late _FakeBlePlatform platform;
  late UniversalBleTransport transport;

  setUp(() {
    platform = _FakeBlePlatform();
    UniversalBle.setInstance(platform);
    UniversalBle.queueType = QueueType.none;
    transport = UniversalBleTransport();
  });

  tearDown(() async {
    await transport.dispose();
  });

  test(
    'requests permission, scans and maps named and unnamed devices',
    () async {
      platform.permissions = false;
      final devices = <BleDeviceInfo>[];
      final subscription = transport.scan().listen(devices.add);
      await Future<void>.delayed(Duration.zero);
      expect(platform.permissionRequests, 1);
      expect(platform.startScanCalls, 1);

      platform.updateScanResult(
        BleDevice(
          deviceId: 'one',
          name: 'SK120',
          rssi: -40,
          services: const ['FFE0'],
        ),
      );
      platform.updateScanResult(
        BleDevice(deviceId: 'two', name: '', rssi: -80),
      );
      await Future<void>.delayed(Duration.zero);
      expect(devices.first.name, 'SK120');
      expect(devices.first.serviceUuids, ['FFE0']);
      expect(devices.last.name, '未命名 BLE 设备');
      await subscription.cancel();
    },
  );

  test(
    'scan failures are swallowed while stop failures become results',
    () async {
      platform.startScanError = StateError('scan failed');
      transport.scan();
      await Future<void>.delayed(Duration.zero);
      platform.stopScanError = StateError('stop failed');
      final failed = await transport.stopScan();
      expect(failed.isFailure, isTrue);
      expect(failed.error?.message, '停止扫描失败');
      platform.stopScanError = null;
      expect((await transport.stopScan()).isSuccess, isTrue);
    },
  );

  test(
    'connect publishes states, ignores other ids and maps failures',
    () async {
      final states = <DeviceConnectionState>[];
      final subscription = transport.connectionStates.listen(states.add);
      expect((await transport.connect('device-a')).isSuccess, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(
        states,
        containsAllInOrder([
          DeviceConnectionState.connecting,
          DeviceConnectionState.connected,
        ]),
      );
      platform.updateConnection('other', false);
      platform.updateConnection('device-a', false);
      await Future<void>.delayed(Duration.zero);
      expect(states.last, DeviceConnectionState.disconnected);

      platform.connectError = StateError('connect failed');
      final failed = await transport.connect('device-b');
      await Future<void>.delayed(Duration.zero);
      expect(failed.isFailure, isTrue);
      expect(failed.error?.message, 'BLE 连接失败');
      expect(states.last, DeviceConnectionState.error);
      await subscription.cancel();
    },
  );

  test(
    'discovers required UUIDs and reports missing service or notify',
    () async {
      expect(
        (await transport.discoverServices()).error?.message,
        '尚未选择 BLE 设备',
      );
      await transport.connect('device-a');

      platform.services = [];
      expect(
        (await transport.discoverServices()).error?.message,
        contains('FFE0'),
      );
      platform.services = [BleService('FFE0', [])];
      expect(
        (await transport.discoverServices()).error?.message,
        contains('FFE1'),
      );
      platform.services = [
        BleService('1800', []),
        BleService('0000FFE0-0000-1000-8000-00805F9B34FB', [
          BleCharacteristic('FFE1', const [], const []),
          BleCharacteristic('FFE2', const [], const []),
        ]),
      ];
      expect((await transport.discoverServices()).isSuccess, isTrue);
      expect(platform.discoverWithDescriptors, isTrue);
    },
  );

  test(
    'discovery exceptions and subscription preconditions are failures',
    () async {
      expect((await transport.subscribe()).error?.message, 'BLE 服务尚未发现');
      await transport.connect('device-a');
      platform.discoverError = StateError('discovery failed');
      final failed = await transport.discoverServices();
      expect(failed.error?.message, 'BLE 服务发现失败');
    },
  );

  test(
    'subscribes, forwards bytes and writes through resolved UUIDs',
    () async {
      await transport.connect('device-a');
      platform.services = [
        BleService('FFE0', [
          BleCharacteristic('FFE1', const [], const []),
          BleCharacteristic('FFE2', const [], const []),
        ]),
      ];
      await transport.discoverServices();
      final incoming = <List<int>>[];
      final subscription = transport.incomingBytes.listen(incoming.add);
      expect((await transport.subscribe()).isSuccess, isTrue);
      platform.updateCharacteristicValue(
        'device-a',
        'FFE1',
        Uint8List.fromList([1, 2, 3]),
        null,
      );
      await Future<void>.delayed(Duration.zero);
      expect(incoming, [
        [1, 2, 3],
      ]);

      expect((await transport.writeFrame([4, 5])).isSuccess, isTrue);
      expect(platform.lastWrite?.deviceId, 'device-a');
      expect(platform.lastWrite?.service, BleUuidParser.string('FFE0'));
      expect(platform.lastWrite?.characteristic, BleUuidParser.string('FFE2'));
      expect(platform.lastWrite?.value, [4, 5]);
      expect(platform.lastWrite?.property, BleOutputProperty.withResponse);
      await subscription.cancel();
    },
  );

  test(
    'falls back to notify characteristic and maps subscribe/write errors',
    () async {
      expect((await transport.writeFrame([1])).error?.message, 'BLE 服务尚未连接');
      await transport.connect('device-a');
      platform.services = [
        BleService('FFE0', [BleCharacteristic('FFE1', const [], const [])]),
      ];
      await transport.discoverServices();
      platform.notifyError = StateError('notify failed');
      expect((await transport.subscribe()).error?.message, 'BLE 通知订阅失败');
      platform.notifyError = null;
      expect((await transport.subscribe()).isSuccess, isTrue);
      platform.writeError = StateError('write failed');
      expect((await transport.writeFrame([1])).error?.message, 'BLE 写入失败');
      platform.writeError = null;
      await transport.writeFrame([2]);
      expect(platform.lastWrite?.characteristic, BleUuidParser.string('FFE1'));
    },
  );

  test('disconnect and reconnect clean up selected device', () async {
    expect((await transport.disconnect()).isSuccess, isTrue);
    await transport.connect('device-a');
    expect((await transport.reconnect('device-b')).isSuccess, isTrue);
    expect(platform.disconnectedIds, contains('device-a'));
    expect(platform.connectedIds.last, 'device-b');
    expect((await transport.disconnect()).isSuccess, isTrue);
  });
}

class _FakeBlePlatform extends UniversalBlePlatform {
  bool permissions = true;
  int permissionRequests = 0;
  int startScanCalls = 0;
  Object? startScanError;
  Object? stopScanError;
  Object? connectError;
  Object? discoverError;
  Object? notifyError;
  Object? writeError;
  List<BleService> services = [];
  bool discoverWithDescriptors = false;
  final List<String> connectedIds = [];
  final List<String> disconnectedIds = [];
  ({
    String deviceId,
    String service,
    String characteristic,
    List<int> value,
    BleOutputProperty property,
  })?
  lastWrite;

  @override
  Future<bool> hasPermissions({bool withAndroidFineLocation = false}) async =>
      permissions;

  @override
  Future<void> requestPermissions({
    bool withAndroidFineLocation = false,
  }) async {
    permissionRequests++;
    permissions = true;
  }

  @override
  Future<void> startScan({
    ScanFilter? scanFilter,
    PlatformConfig? platformConfig,
  }) async {
    startScanCalls++;
    if (startScanError case final error?) throw error;
  }

  @override
  Future<void> stopScan() async {
    if (stopScanError case final error?) throw error;
  }

  @override
  Future<void> connect(
    String deviceId, {
    Duration? connectionTimeout,
    bool autoConnect = false,
    ConnectionPlatformConfig? platformConfig,
  }) async {
    connectedIds.add(deviceId);
    if (connectError case final error?) throw error;
    scheduleMicrotask(() => updateConnection(deviceId, true));
  }

  @override
  Future<void> disconnect(String deviceId) async {
    disconnectedIds.add(deviceId);
    scheduleMicrotask(() => updateConnection(deviceId, false));
  }

  @override
  Future<BleConnectionState> getConnectionState(String deviceId) async =>
      BleConnectionState.connected;

  @override
  Future<List<BleService>> discoverServices(
    String deviceId,
    bool withDescriptors,
  ) async {
    discoverWithDescriptors = withDescriptors;
    if (discoverError case final error?) throw error;
    return services;
  }

  @override
  Future<void> setNotifiable(
    String deviceId,
    String service,
    String characteristic,
    BleInputProperty bleInputProperty,
  ) async {
    if (notifyError case final error?) throw error;
  }

  @override
  Future<void> writeValue(
    String deviceId,
    String service,
    String characteristic,
    Uint8List value,
    BleOutputProperty bleOutputProperty,
  ) async {
    if (writeError case final error?) throw error;
    lastWrite = (
      deviceId: deviceId,
      service: service,
      characteristic: characteristic,
      value: value.toList(),
      property: bleOutputProperty,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
