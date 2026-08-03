import 'dart:async';

import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../models/device_models.dart';
import 'device_polling_service.dart';

abstract interface class PowerDevice {
  String get id;
  String get name;
  DeviceMode get mode;
  DeviceStatus get status;
  Stream<DeviceStatus> get statusStream;

  Stream<BleDeviceInfo> scan();
  Future<Result<void>> stopScan();
  Future<Result<void>> connect({String? deviceId});
  Future<Result<void>> disconnect();
  Future<Result<DeviceStatus>> readStatus();
  Future<Result<void>> setVoltage(double volts);
  Future<Result<void>> setCurrent(double amps);
  Future<Result<void>> setOutput(bool enabled);
  Future<Result<DataGroup>> readDataGroup(int index);
  Future<Result<void>> writeDataGroup(DataGroup group);
  Future<Result<void>> activateDataGroup(int index);
  Future<Result<void>> setBuzzer(bool enabled);
  Future<Result<void>> setKeyLock(bool locked);
  Future<Result<void>> setBacklight(int level);
  Future<Result<void>> setSleepMinutes(int minutes);
  Future<Result<void>> setSlaveAddress(int address);
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate);
  Future<Result<void>> setMppt({required bool enabled, int? coefficient});
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  });
  Future<Result<void>> dispose();
}

abstract class PowerDeviceBase implements PowerDevice {
  PowerDeviceBase({
    required this.id,
    required this.name,
    required this.mode,
    required DeviceStatus initialStatus,
  }) : _status = initialStatus;

  @override
  final String id;

  @override
  final String name;

  @override
  final DeviceMode mode;

  DeviceStatus _status;
  final StreamController<DeviceStatus> _statusController =
      StreamController<DeviceStatus>.broadcast();

  @override
  DeviceStatus get status => _status;

  @override
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  void emitStatus(DeviceStatus next) {
    _status = next.copyWith(lastUpdated: DateTime.now());
    if (!_statusController.isClosed) _statusController.add(_status);
  }

  Failure<T> failure<T>(
    ErrorCode code,
    String message, {
    String? details,
    Object? cause,
  }) => Failure(
    AppError(code: code, message: message, details: details, cause: cause),
  );

  @override
  Stream<BleDeviceInfo> scan() => const Stream.empty();

  @override
  Future<Result<void>> stopScan() async => const Success(null);

  @override
  Future<Result<void>> setBuzzer(bool enabled) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持蜂鸣器设置');

  @override
  Future<Result<void>> setKeyLock(bool locked) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持按键锁设置');

  @override
  Future<Result<void>> activateDataGroup(int index) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持调用数据组');

  @override
  Future<Result<void>> setBacklight(int level) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持背光设置');

  @override
  Future<Result<void>> setSleepMinutes(int minutes) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持息屏设置');

  @override
  Future<Result<void>> setSlaveAddress(int address) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持从机地址设置');

  @override
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) async =>
      failure(ErrorCode.deviceNotReady, '当前设备不支持波特率设置');

  @override
  Future<Result<void>> setMppt({
    required bool enabled,
    int? coefficient,
  }) async => failure(ErrorCode.deviceNotReady, '当前设备不支持 MPPT 设置');

  @override
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  }) async => failure(ErrorCode.deviceNotReady, '当前设备不支持恒功率设置');

  @override
  Future<Result<void>> dispose() async {
    await _statusController.close();
    return const Success(null);
  }
}

class PowerDeviceService {
  PowerDeviceService(this.device, {this.onSample, this.onSession}) {
    _previousStatus = device.status;
    _polling = DevicePollingService(device: device, onSample: _handleSample);
    _connectionSubscription = device.statusStream.listen((next) {
      final previous = _previousStatus;
      if (previous.outputState != OutputState.on &&
          next.outputState == OutputState.on) {
        _sessionStartedAt = DateTime.now();
        _sessionSamples.clear();
      } else if (previous.outputState == OutputState.on &&
          next.outputState == OutputState.off) {
        _finishSession(next);
      }
      _previousStatus = next;
      if (next.connectionState == DeviceConnectionState.disconnected &&
          device.mode == DeviceMode.real &&
          !_manualDisconnect) {
        _scheduleReconnect();
      }
    });
  }

  final PowerDevice device;
  final void Function(MeasurementSample sample)? onSample;
  final void Function(OutputSession session)? onSession;
  late final DevicePollingService _polling;
  StreamSubscription<DeviceStatus>? _connectionSubscription;
  final StreamController<MeasurementSample> _sampleController =
      StreamController<MeasurementSample>.broadcast();
  Timer? _reconnectTimer;
  String? _lastDeviceId;
  bool _manualDisconnect = true;
  bool _reconnecting = false;
  late DeviceStatus _previousStatus;
  DateTime? _sessionStartedAt;
  final List<MeasurementSample> _sessionSamples = [];

  DeviceStatus get previousStatus => _previousStatus;

  Stream<DeviceStatus> get statusStream => device.statusStream;
  Stream<BleDeviceInfo> scan() => device.scan();
  Future<Result<void>> stopScan() => device.stopScan();
  DeviceStatus get status => device.status;
  String get id => device.id;
  String get name => device.name;
  DeviceMode get mode => device.mode;
  Stream<MeasurementSample> get sampleStream => _sampleController.stream;

  // The first status is captured after the device field is initialized.
  void _handleSample(MeasurementSample sample) {
    onSample?.call(sample);
    if (!_sampleController.isClosed) _sampleController.add(sample);
    if (sample.outputState == OutputState.on) _sessionSamples.add(sample);
  }

  void _finishSession(DeviceStatus endingStatus) {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;
    final samples = List<MeasurementSample>.from(_sessionSamples);
    final voltages = samples
        .map((sample) => sample.voltage)
        .whereType<double>()
        .toList();
    final currents = samples
        .map((sample) => sample.current)
        .whereType<double>()
        .toList();
    final powers = samples
        .map((sample) => sample.power)
        .whereType<double>()
        .toList();
    onSession?.call(
      OutputSession(
        deviceId: device.id,
        startTime: startedAt,
        endTime: DateTime.now(),
        outputDuration: endingStatus.outputDuration,
        averageVoltage: voltages.isEmpty
            ? null
            : voltages.reduce((a, b) => a + b) / voltages.length,
        averageCurrent: currents.isEmpty
            ? null
            : currents.reduce((a, b) => a + b) / currents.length,
        maxPower: powers.isEmpty
            ? null
            : powers.reduce((a, b) => a > b ? a : b),
        totalAh: endingStatus.outputAh,
        totalWh: endingStatus.outputWh,
      ),
    );
    _sessionStartedAt = null;
    _sessionSamples.clear();
  }

  Future<Result<void>> connect({String? deviceId}) async {
    _manualDisconnect = false;
    _lastDeviceId = deviceId ?? device.id;
    final result = await device.connect(deviceId: deviceId);
    if (result.isSuccess) await _polling.start();
    return result;
  }

  Future<Result<void>> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _polling.stop();
    return device.disconnect();
  }

  void _scheduleReconnect() {
    if (_reconnecting || _manualDisconnect || _lastDeviceId == null) return;
    _reconnecting = true;
    var attempt = 0;
    const delays = [1, 2, 4, 8, 16];
    Future<void> retry() async {
      if (_manualDisconnect ||
          device.status.isConnected ||
          attempt >= delays.length) {
        _reconnecting = false;
        return;
      }
      _reconnectTimer = Timer(Duration(seconds: delays[attempt++]), () async {
        if (_manualDisconnect) {
          _reconnecting = false;
          return;
        }
        final result = await device.connect(deviceId: _lastDeviceId);
        if (result.isSuccess) {
          _reconnecting = false;
          await _polling.start();
        } else {
          await retry();
        }
      });
    }

    unawaited(retry());
  }

  Future<void> stopReconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnecting = false;
  }

  Future<Result<DeviceStatus>> readStatus() => device.readStatus();
  Future<Result<void>> setVoltage(double value) => device.setVoltage(value);
  Future<Result<void>> setCurrent(double value) => device.setCurrent(value);
  Future<Result<void>> setOutput(bool enabled) => device.setOutput(enabled);
  Future<Result<DataGroup>> readDataGroup(int index) =>
      device.readDataGroup(index);
  Future<Result<void>> writeDataGroup(DataGroup group) =>
      device.writeDataGroup(group);
  Future<Result<void>> activateDataGroup(int index) =>
      device.activateDataGroup(index);
  Future<Result<void>> setBuzzer(bool enabled) => device.setBuzzer(enabled);
  Future<Result<void>> setKeyLock(bool locked) => device.setKeyLock(locked);
  Future<Result<void>> setBacklight(int level) => device.setBacklight(level);
  Future<Result<void>> setSleepMinutes(int minutes) =>
      device.setSleepMinutes(minutes);
  Future<Result<void>> setSlaveAddress(int address) =>
      device.setSlaveAddress(address);
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) =>
      device.setBaudRate(baudRate);
  Future<Result<void>> setMppt({required bool enabled, int? coefficient}) =>
      device.setMppt(enabled: enabled, coefficient: coefficient);
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  }) => device.setConstantPower(enabled: enabled, watts: watts);
  Future<Result<void>> dispose() async {
    await stopReconnect();
    await _polling.dispose();
    await _connectionSubscription?.cancel();
    await _sampleController.close();
    return device.dispose();
  }
}
