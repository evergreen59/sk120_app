import 'dart:async';
import 'dart:math' as math;

import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../models/device_models.dart';
import '../protocol/registers.dart';
import 'power_device.dart';

class MockPowerDevice extends PowerDeviceBase {
  MockPowerDevice()
    : _groups = List<DataGroup>.generate(
        RegisterCatalog.dataGroupCount,
        (index) => DataGroup(
          index: index,
          name: 'M$index',
          voltageSet: 12,
          currentSet: 1.25,
          lowVoltageProtection: 10,
          overVoltageProtection: 14,
          overCurrentProtection: 2,
          overPowerProtection: 20,
          maxOutputHours: 4,
          maxOutputMinutes: 0,
          maxOutputAh: 5000,
          maxOutputWh: 60000,
          overTemperatureProtection: 70,
          powerOnOutput: 0,
          externalTemperatureProtection: 0,
        ),
      ),
      super(
        id: 'mock-sk120',
        name: 'XY-SK120 Demo',
        mode: DeviceMode.mock,
        initialStatus: const DeviceStatus(
          outputState: OutputState.off,
          cvccState: CvccState.cv,
          protectionStatus: ProtectionStatus.normal,
          protectionRaw: 0,
          keyLocked: false,
          buzzerEnabled: false,
          backlightLevel: 3,
          voltageSet: 12,
          currentSet: 1.25,
          outputVoltage: 0,
          outputCurrent: 0,
          outputPower: 0,
          inputVoltage: 24.1,
          outputAh: 0,
          outputWh: 0,
          internalTemperature: 32.5,
          externalTemperature: 31.8,
          model: 'XY-SK120 Mock',
          firmwareVersion: 'demo-1.0',
          slaveAddress: 1,
          baudRate: DeviceBaudRate.baud115200,
          baudRateRaw: 6,
          mpptEnabled: false,
          mpptCoefficient: 0,
          constantPowerEnabled: false,
          constantPowerValue: 0,
        ),
      );

  final List<DataGroup> _groups;
  DateTime? _outputStarted;
  DateTime? _lastRead;
  int _ah = 0;
  int _wh = 0;

  @override
  Stream<BleDeviceInfo> scan() => Stream<BleDeviceInfo>.fromIterable(const [
    BleDeviceInfo(id: 'mock-sk120', name: 'XY-SK120 Demo', rssi: -35),
  ]);

  @override
  Future<Result<void>> connect({String? deviceId}) async {
    emitStatus(
      status.copyWith(connectionState: DeviceConnectionState.connecting),
    );
    await Future<void>.delayed(const Duration(milliseconds: 90));
    emitStatus(
      status.copyWith(
        connectionState: DeviceConnectionState.connected,
        outputState: OutputState.off,
      ),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> disconnect() async {
    _outputStarted = null;
    emitStatus(
      status.copyWith(
        connectionState: DeviceConnectionState.disconnected,
        outputState: OutputState.unknown,
      ),
    );
    return const Success(null);
  }

  @override
  Future<Result<DeviceStatus>> readStatus() async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    final now = DateTime.now();
    final elapsed = _lastRead == null
        ? 0.0
        : now.difference(_lastRead!).inMilliseconds / 1000;
    _lastRead = now;
    final enabled = status.outputState == OutputState.on;
    if (enabled && elapsed > 0) {
      final current = status.currentSet ?? 0;
      _ah += (current * elapsed * 1000 / 3600).round();
      _wh +=
          ((status.outputVoltage ?? status.voltageSet ?? 0) *
                  current *
                  elapsed *
                  1000 /
                  3600)
              .round();
    }
    final voltage = enabled ? (status.voltageSet ?? 0) : 0.0;
    final current = enabled ? (status.currentSet ?? 0) : 0.0;
    final temperature =
        32.5 + math.sin(now.millisecondsSinceEpoch / 2400) * 0.7;
    final next = status.copyWith(
      outputVoltage: voltage,
      outputCurrent: current,
      outputPower: voltage * current,
      inputVoltage: 24.1 + math.sin(now.millisecondsSinceEpoch / 5000) * 0.2,
      outputAh: _ah,
      outputWh: _wh,
      outputDuration: _outputStarted == null
          ? Duration.zero
          : now.difference(_outputStarted!),
      internalTemperature: temperature,
      externalTemperature: temperature - 0.6,
    );
    emitStatus(next);
    return Success(status);
  }

  @override
  Future<Result<void>> setVoltage(double volts) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    try {
      final raw = RegisterCatalog.encodeVoltage(volts);
      emitStatus(status.copyWith(voltageSet: raw / 100));
      return const Success(null);
    } on ArgumentError catch (error) {
      return failure(
        ErrorCode.invalidRegisterValue,
        error.message?.toString() ?? '电压值无效',
        cause: error,
      );
    }
  }

  @override
  Future<Result<void>> setCurrent(double amps) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    try {
      final raw = RegisterCatalog.encodeCurrent(amps);
      emitStatus(status.copyWith(currentSet: raw / 1000));
      return const Success(null);
    } on ArgumentError catch (error) {
      return failure(
        ErrorCode.invalidRegisterValue,
        error.message?.toString() ?? '电流值无效',
        cause: error,
      );
    }
  }

  @override
  Future<Result<void>> setOutput(bool enabled) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (enabled && (status.voltageSet == null || status.currentSet == null)) {
      return failure(ErrorCode.deviceNotReady, '设定值尚未读取');
    }
    _outputStarted = enabled ? DateTime.now() : null;
    emitStatus(
      status.copyWith(outputState: enabled ? OutputState.on : OutputState.off),
    );
    return const Success(null);
  }

  @override
  Future<Result<DataGroup>> readDataGroup(int index) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (index < 0 || index >= _groups.length) {
      return failure(ErrorCode.invalidRegisterValue, '数据组编号无效');
    }
    await Future<void>.delayed(const Duration(milliseconds: 70));
    return Success(_groups[index]);
  }

  @override
  Future<Result<void>> writeDataGroup(DataGroup group) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (status.outputState == OutputState.on) {
      return failure(ErrorCode.deviceNotReady, '输出开启时不能写入数据组');
    }
    if (!group.isValidIndex) {
      return failure(ErrorCode.invalidRegisterValue, '数据组编号无效');
    }
    if (group.voltageSet != null &&
        (group.voltageSet! < 0 || group.voltageSet! > 36)) {
      return failure(ErrorCode.invalidRegisterValue, '数据组电压超出范围');
    }
    if (group.currentSet != null &&
        (group.currentSet! < 0 || group.currentSet! > 5)) {
      return failure(ErrorCode.invalidRegisterValue, '数据组电流超出范围');
    }
    _groups[group.index] = group;
    return const Success(null);
  }

  @override
  Future<Result<void>> activateDataGroup(int index) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (index < 0 || index >= _groups.length) {
      return failure(ErrorCode.invalidRegisterValue, '数据组编号无效');
    }
    if (status.outputState != OutputState.off) {
      return failure(ErrorCode.deviceNotReady, '仅可在输出关闭时调用数据组');
    }
    final group = _groups[index];
    emitStatus(
      status.copyWith(
        voltageSet: group.voltageSet,
        currentSet: group.currentSet,
      ),
    );
    final refreshed = await readStatus();
    return refreshed.isSuccess
        ? const Success(null)
        : Failure(refreshed.error!);
  }

  @override
  Future<Result<void>> setBuzzer(bool enabled) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    emitStatus(status.copyWith(buzzerEnabled: enabled));
    return const Success(null);
  }

  @override
  Future<Result<void>> setKeyLock(bool locked) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    emitStatus(status.copyWith(keyLocked: locked));
    return const Success(null);
  }

  @override
  Future<Result<void>> setBacklight(int level) async {
    if (!status.isConnected || level < 0 || level > 5) {
      return failure(ErrorCode.invalidRegisterValue, '背光等级无效');
    }
    emitStatus(status.copyWith(backlightLevel: level));
    return const Success(null);
  }

  @override
  Future<Result<void>> setSleepMinutes(int minutes) async {
    if (!status.isConnected || minutes < 0 || minutes > 255) {
      return failure(ErrorCode.invalidRegisterValue, '息屏时间无效');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> setSlaveAddress(int address) async {
    if (!status.isConnected || address < 1 || address > 255) {
      return failure(ErrorCode.invalidRegisterValue, '从机地址必须在 1-255');
    }
    emitStatus(status.copyWith(slaveAddress: address));
    return const Success(null);
  }

  @override
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    emitStatus(status.copyWith(baudRate: baudRate, baudRateRaw: baudRate.code));
    return const Success(null);
  }

  @override
  Future<Result<void>> setMppt({
    required bool enabled,
    int? coefficient,
  }) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    emitStatus(
      status.copyWith(
        mpptEnabled: enabled,
        mpptCoefficient: coefficient ?? status.mpptCoefficient,
      ),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  }) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    try {
      RegisterCatalog.encodePower(watts);
    } on ArgumentError catch (error) {
      return failure(
        ErrorCode.invalidRegisterValue,
        error.message?.toString() ?? '功率值无效',
        cause: error,
      );
    }
    emitStatus(
      status.copyWith(constantPowerEnabled: enabled, constantPowerValue: watts),
    );
    return const Success(null);
  }
}
