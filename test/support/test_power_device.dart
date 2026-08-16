import 'dart:async';

import 'package:xy_sk120_control/core/errors/app_error.dart';
import 'package:xy_sk120_control/core/result/result.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';

class TestPowerDevice extends PowerDeviceBase {
  TestPowerDevice({
    super.mode = DeviceMode.real,
    DeviceStatus status = const DeviceStatus(),
  }) : super(id: 'test-device', name: 'Test Device', initialStatus: status);

  final StreamController<BleDeviceInfo> scanController =
      StreamController<BleDeviceInfo>.broadcast();
  final List<String> calls = [];
  final List<double> voltages = [];
  final List<double> currents = [];
  final List<bool> outputs = [];
  final List<int> activatedGroups = [];
  final List<DataGroup> writtenGroups = [];

  Result<void> connectResult = const Success(null);
  final List<Result<void>> connectResults = [];
  Result<void> disconnectResult = const Success(null);
  Result<void> operationResult = const Success(null);
  Result<DeviceStatus>? readResult;
  Result<DataGroup>? groupResult;
  Duration readDelay = Duration.zero;
  int readCount = 0;

  void publish(DeviceStatus next) => emitStatus(next);

  @override
  Stream<BleDeviceInfo> scan() {
    calls.add('scan');
    return scanController.stream;
  }

  @override
  Future<Result<void>> stopScan() async {
    calls.add('stopScan');
    return operationResult;
  }

  @override
  Future<Result<void>> connect({String? deviceId}) async {
    calls.add('connect:${deviceId ?? id}');
    final result = connectResults.isEmpty
        ? connectResult
        : connectResults.removeAt(0);
    if (result.isSuccess) {
      emitStatus(
        status.copyWith(connectionState: DeviceConnectionState.connected),
      );
    }
    return result;
  }

  @override
  Future<Result<void>> disconnect() async {
    calls.add('disconnect');
    if (disconnectResult.isSuccess) {
      emitStatus(
        status.copyWith(
          connectionState: DeviceConnectionState.disconnected,
          outputState: OutputState.unknown,
        ),
      );
    }
    return disconnectResult;
  }

  @override
  Future<Result<DeviceStatus>> readStatus() async {
    calls.add('readStatus');
    readCount++;
    if (readDelay > Duration.zero) await Future<void>.delayed(readDelay);
    final result = readResult ?? Success(status);
    if (result.isSuccess) emitStatus(result.value!);
    return result;
  }

  @override
  Future<Result<void>> setVoltage(double volts) async {
    calls.add('setVoltage');
    voltages.add(volts);
    if (operationResult.isSuccess) {
      emitStatus(status.copyWith(voltageSet: volts));
    }
    return operationResult;
  }

  @override
  Future<Result<void>> setCurrent(double amps) async {
    calls.add('setCurrent');
    currents.add(amps);
    if (operationResult.isSuccess) {
      emitStatus(status.copyWith(currentSet: amps));
    }
    return operationResult;
  }

  @override
  Future<Result<void>> setOutput(bool enabled) async {
    calls.add('setOutput');
    outputs.add(enabled);
    if (operationResult.isSuccess) {
      emitStatus(
        status.copyWith(
          outputState: enabled ? OutputState.on : OutputState.off,
        ),
      );
    }
    return operationResult;
  }

  @override
  Future<Result<DataGroup>> readDataGroup(int index) async {
    calls.add('readGroup:$index');
    return groupResult ?? Success(DataGroup(index: index, name: 'M$index'));
  }

  @override
  Future<Result<void>> writeDataGroup(DataGroup group) async {
    calls.add('writeGroup:${group.index}');
    writtenGroups.add(group);
    return operationResult;
  }

  @override
  Future<Result<void>> activateDataGroup(int index) async {
    calls.add('activateGroup:$index');
    activatedGroups.add(index);
    return operationResult;
  }

  @override
  Future<Result<void>> setBuzzer(bool enabled) async {
    calls.add('setBuzzer:$enabled');
    return operationResult;
  }

  @override
  Future<Result<void>> setKeyLock(bool locked) async {
    calls.add('setKeyLock:$locked');
    if (operationResult.isSuccess) {
      emitStatus(status.copyWith(keyLocked: locked));
    }
    return operationResult;
  }

  @override
  Future<Result<void>> setBacklight(int level) async {
    calls.add('setBacklight:$level');
    if (operationResult.isSuccess) {
      emitStatus(status.copyWith(backlightLevel: level));
    }
    return operationResult;
  }

  @override
  Future<Result<void>> setSleepMinutes(int minutes) async {
    calls.add('setSleep:$minutes');
    return operationResult;
  }

  @override
  Future<Result<void>> setSlaveAddress(int address) async {
    calls.add('setAddress:$address');
    return operationResult;
  }

  @override
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) async {
    calls.add('setBaud:${baudRate.code}');
    return operationResult;
  }

  @override
  Future<Result<void>> setMppt({
    required bool enabled,
    int? coefficient,
  }) async {
    calls.add('setMppt:$enabled:$coefficient');
    return operationResult;
  }

  @override
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  }) async {
    calls.add('setPower:$enabled:$watts');
    return operationResult;
  }

  void failOperations([String message = 'test failure']) {
    operationResult = Failure(
      AppError(code: ErrorCode.unknown, message: message),
    );
  }

  @override
  Future<Result<void>> dispose() async {
    if (!scanController.isClosed) await scanController.close();
    return super.dispose();
  }
}
