import 'dart:async';
import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart';

import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../domain/models/device_models.dart';
import '../../domain/repositories/ble_transport.dart';

class UniversalBleTransport implements BleTransport {
  UniversalBleTransport() {
    UniversalBle.onConnectionChange = (deviceId, isConnected, error) {
      if (deviceId != _deviceId) return;
      _connectionController.add(
        isConnected
            ? DeviceConnectionState.connected
            : DeviceConnectionState.disconnected,
      );
    };
  }

  static const String _serviceUuid = 'FFE0';
  static const String _notifyCharacteristicUuid = 'FFE1';
  static const String _writeCharacteristicUuid = 'FFE2';

  final StreamController<List<int>> _incomingController =
      StreamController<List<int>>.broadcast();
  final StreamController<DeviceConnectionState> _connectionController =
      StreamController<DeviceConnectionState>.broadcast();
  StreamSubscription<Uint8List>? _valueSubscription;
  String? _deviceId;
  String? _resolvedServiceUuid;
  String? _resolvedNotifyUuid;
  String? _resolvedWriteUuid;

  @override
  Stream<List<int>> get incomingBytes => _incomingController.stream;

  @override
  Stream<DeviceConnectionState> get connectionStates =>
      _connectionController.stream;

  @override
  Stream<BleDeviceInfo> scan() {
    unawaited(_startScan());
    return UniversalBle.scanStream.map(
      (device) => BleDeviceInfo(
        id: device.deviceId,
        name: device.name?.isNotEmpty == true ? device.name! : '未命名 BLE 设备',
        rssi: device.rssi,
        serviceUuids: device.services,
      ),
    );
  }

  Future<void> _startScan() async {
    try {
      if (!await UniversalBle.hasPermissions(withAndroidFineLocation: false)) {
        await UniversalBle.requestPermissions(withAndroidFineLocation: false);
      }
      await UniversalBle.startScan(
        platformConfig: PlatformConfig(
          android: AndroidOptions(requestLocationPermission: false),
        ),
      );
    } catch (_) {
      // Scan errors are surfaced by the stream/platform on the next operation.
    }
  }

  @override
  Future<Result<void>> stopScan() async {
    try {
      await UniversalBle.stopScan();
      return const Success(null);
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: '停止扫描失败', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> connect(String deviceId) async {
    _deviceId = deviceId;
    _connectionController.add(DeviceConnectionState.connecting);
    try {
      if (!await UniversalBle.hasPermissions(withAndroidFineLocation: false)) {
        await UniversalBle.requestPermissions(withAndroidFineLocation: false);
      }
      await UniversalBle.stopScan();
      await UniversalBle.connect(
        deviceId,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      _connectionController.add(DeviceConnectionState.connected);
      return const Success(null);
    } catch (error) {
      _connectionController.add(DeviceConnectionState.error);
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 连接失败', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> reconnect(String deviceId) async {
    await disconnect();
    return connect(deviceId);
  }

  @override
  Future<Result<void>> disconnect() async {
    final deviceId = _deviceId;
    await _valueSubscription?.cancel();
    _valueSubscription = null;
    if (deviceId == null) return const Success(null);
    try {
      await UniversalBle.disconnect(deviceId);
      _connectionController.add(DeviceConnectionState.disconnected);
      return const Success(null);
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 断开失败', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> discoverServices() async {
    final deviceId = _deviceId;
    if (deviceId == null) {
      return const Failure(
        AppError(code: ErrorCode.deviceNotReady, message: '尚未选择 BLE 设备'),
      );
    }
    try {
      final services = await UniversalBle.discoverServices(
        deviceId,
        withDescriptors: true,
      );
      BleService? service;
      for (final candidate in services) {
        if (bleUuidsEqual(candidate.uuid, _serviceUuid)) {
          service = candidate;
          break;
        }
      }
      if (service == null) {
        return const Failure(
          AppError(code: ErrorCode.bleError, message: '未发现 XY-SK120 服务 FFE0'),
        );
      }
      BleCharacteristic? notify;
      BleCharacteristic? write;
      for (final characteristic in service.characteristics) {
        if (bleUuidsEqual(characteristic.uuid, _notifyCharacteristicUuid)) {
          notify = characteristic;
        }
        if (bleUuidsEqual(characteristic.uuid, _writeCharacteristicUuid)) {
          write = characteristic;
        }
      }
      if (notify == null) {
        return const Failure(
          AppError(code: ErrorCode.bleError, message: '未发现通知特征 FFE1'),
        );
      }
      _resolvedServiceUuid = service.uuid;
      _resolvedNotifyUuid = notify.uuid;
      _resolvedWriteUuid = write?.uuid ?? notify.uuid;
      return const Success(null);
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 服务发现失败', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> subscribe() async {
    final deviceId = _deviceId;
    final serviceUuid = _resolvedServiceUuid;
    final notifyUuid = _resolvedNotifyUuid;
    if (deviceId == null || serviceUuid == null || notifyUuid == null) {
      return const Failure(
        AppError(code: ErrorCode.deviceNotReady, message: 'BLE 服务尚未发现'),
      );
    }
    try {
      await UniversalBle.subscribeNotifications(
        deviceId,
        serviceUuid,
        notifyUuid,
      );
      await _valueSubscription?.cancel();
      _valueSubscription = UniversalBle.characteristicValueStream(
        deviceId,
        notifyUuid,
      ).listen(_incomingController.add);
      return const Success(null);
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 通知订阅失败', cause: error),
      );
    }
  }

  @override
  Future<Result<void>> writeFrame(List<int> bytes) async {
    final deviceId = _deviceId;
    final serviceUuid = _resolvedServiceUuid;
    final writeUuid = _resolvedWriteUuid;
    if (deviceId == null || serviceUuid == null || writeUuid == null) {
      return const Failure(
        AppError(code: ErrorCode.deviceNotReady, message: 'BLE 服务尚未连接'),
      );
    }
    try {
      await UniversalBle.write(
        deviceId,
        serviceUuid,
        writeUuid,
        Uint8List.fromList(bytes),
        withoutResponse: false,
      );
      return const Success(null);
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 写入失败', cause: error),
      );
    }
  }

  Future<void> dispose() async {
    await _valueSubscription?.cancel();
    await _incomingController.close();
    await _connectionController.close();
  }
}

const String _bluetoothBaseUuidSuffix = '00001000800000805f9b34fb';

bool bleUuidsEqual(String first, String second) {
  return _canonicalBleUuid(first) == _canonicalBleUuid(second);
}

String _canonicalBleUuid(String uuid) {
  final compact = uuid
      .trim()
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('{', '')
      .replaceAll('}', '');
  return switch (compact.length) {
    4 => '0000$compact$_bluetoothBaseUuidSuffix',
    8 => '$compact$_bluetoothBaseUuidSuffix',
    _ => compact,
  };
}
