import 'dart:async';

import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../models/device_models.dart';
import '../protocol/modbus_client.dart';
import '../protocol/registers.dart';
import '../repositories/ble_transport.dart';
import 'power_device.dart';

class RealPowerDevice extends PowerDeviceBase {
  RealPowerDevice({
    required this._transport,
    required this._client,
    String deviceId = 'xy-sk120',
  }) : super(
         id: deviceId,
         name: 'XY-SK120',
         mode: DeviceMode.real,
         initialStatus: const DeviceStatus(
           slaveAddress: 1,
           baudRate: DeviceBaudRate.baud115200,
           baudRateRaw: 6,
         ),
       ) {
    _connectionSubscription = _transport.connectionStates.listen((
      connectionState,
    ) {
      emitStatus(
        status.copyWith(
          connectionState: connectionState,
          outputState: connectionState == DeviceConnectionState.connected
              ? status.outputState
              : OutputState.unknown,
        ),
      );
    });
  }

  final BleTransport _transport;
  final ModbusClient _client;
  StreamSubscription<DeviceConnectionState>? _connectionSubscription;

  @override
  Stream<BleDeviceInfo> scan() => _transport.scan();

  @override
  Future<Result<void>> stopScan() => _transport.stopScan();

  @override
  Future<Result<void>> connect({String? deviceId}) async {
    emitStatus(
      status.copyWith(connectionState: DeviceConnectionState.connecting),
    );
    final connected = await _transport.connect(deviceId ?? id);
    if (connected.isFailure) {
      emitStatus(status.copyWith(connectionState: DeviceConnectionState.error));
      return Failure(connected.error!);
    }
    final discovered = await _transport.discoverServices();
    if (discovered.isFailure) return Failure(discovered.error!);
    final subscribed = await _transport.subscribe();
    if (subscribed.isFailure) return Failure(subscribed.error!);
    emitStatus(
      status.copyWith(connectionState: DeviceConnectionState.connected),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> disconnect() async {
    final result = await _transport.disconnect();
    if (result.isSuccess) {
      emitStatus(
        status.copyWith(
          connectionState: DeviceConnectionState.disconnected,
          outputState: OutputState.unknown,
        ),
      );
    }
    return result;
  }

  @override
  Future<Result<DeviceStatus>> readStatus() async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    final firstResult = await _client.readRegisters(
      PowerRegister.voltageSet.address,
      32,
    );
    if (firstResult.isFailure) return Failure(firstResult.error!);
    if (firstResult.value!.length != 32) {
      return failure(ErrorCode.modbusException, '设备返回的基础状态寄存器不足');
    }
    final secondResult = await _client.readRegisters(
      PowerRegister.mpptCoefficient.address,
      4,
    );
    if (secondResult.isFailure) return Failure(secondResult.error!);
    if (secondResult.value!.length != 4) {
      return failure(ErrorCode.modbusException, '设备返回的扩展状态寄存器不足');
    }
    final values = [...firstResult.value!, ...secondResult.value!];
    final protectionRaw = values[PowerRegister.protect.address];
    final baudRateRaw = values[PowerRegister.baudRate.address];
    final next = DeviceStatus(
      connectionState: DeviceConnectionState.connected,
      outputState: _outputState(values[PowerRegister.output.address]),
      cvccState: _cvccState(values[PowerRegister.cvcc.address]),
      protectionStatus: ProtectionStatus.fromCode(protectionRaw),
      protectionRaw: protectionRaw,
      keyLocked: _binary(values[PowerRegister.lock.address]),
      backlightLevel: values[PowerRegister.backlight.address],
      voltageSet: RegisterCatalog.decodeVoltage(
        values[PowerRegister.voltageSet.address],
      ),
      currentSet: RegisterCatalog.decodeCurrent(
        values[PowerRegister.currentSet.address],
      ),
      outputVoltage: RegisterCatalog.decodeVoltage(
        values[PowerRegister.outputVoltage.address],
      ),
      outputCurrent: RegisterCatalog.decodeCurrent(
        values[PowerRegister.outputCurrent.address],
      ),
      outputPower: RegisterCatalog.decodePower(
        values[PowerRegister.outputPower.address],
      ),
      inputVoltage: RegisterCatalog.decodeVoltage(
        values[PowerRegister.inputVoltage.address],
      ),
      outputAh: RegisterCatalog.combineWordPair(
        high: values[PowerRegister.ahHigh.address],
        low: values[PowerRegister.ahLow.address],
      ),
      outputWh: RegisterCatalog.combineWordPair(
        high: values[PowerRegister.whHigh.address],
        low: values[PowerRegister.whLow.address],
      ),
      outputDuration: RegisterCatalog.outputDuration(
        hours: values[PowerRegister.outputHours.address],
        minutes: values[PowerRegister.outputMinutes.address],
        seconds: values[PowerRegister.outputSeconds.address],
      ),
      internalTemperature:
          values[PowerRegister.internalTemperature.address] / 10,
      externalTemperature:
          values[PowerRegister.externalTemperature.address] / 10,
      model: _rawWord(values[PowerRegister.model.address]),
      firmwareVersion: _rawWord(values[PowerRegister.version.address]),
      slaveAddress: values[PowerRegister.slaveAddress.address],
      baudRate: DeviceBaudRate.fromCode(baudRateRaw),
      baudRateRaw: baudRateRaw,
      mpptEnabled: _binary(values[PowerRegister.mpptSwitch.address]),
      mpptCoefficient: values[PowerRegister.mpptCoefficient.address],
      constantPowerEnabled: _binary(
        values[PowerRegister.constantPowerSwitch.address],
      ),
      constantPowerValue: values[PowerRegister.constantPower.address]
          .toDouble(),
      lastUpdated: DateTime.now(),
    );
    emitStatus(next);
    return Success(next);
  }

  @override
  Future<Result<void>> setVoltage(double volts) async {
    try {
      return _client.writeRegister(
        PowerRegister.voltageSet.address,
        RegisterCatalog.encodeVoltage(volts),
      );
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
    try {
      return _client.writeRegister(
        PowerRegister.currentSet.address,
        RegisterCatalog.encodeCurrent(amps),
      );
    } on ArgumentError catch (error) {
      return failure(
        ErrorCode.invalidRegisterValue,
        error.message?.toString() ?? '电流值无效',
        cause: error,
      );
    }
  }

  @override
  Future<Result<void>> setOutput(bool enabled) =>
      _client.writeRegister(PowerRegister.output.address, enabled ? 1 : 0);

  @override
  Future<Result<DataGroup>> readDataGroup(int index) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (index < 0 || index >= RegisterCatalog.dataGroupCount) {
      return failure(ErrorCode.invalidRegisterValue, '数据组编号无效');
    }
    final result = await _client.readRegisters(
      RegisterCatalog.dataGroupAddress(index, DataGroupRegister.voltageSet),
      DataGroupRegister.values.length,
    );
    if (result.isFailure) return Failure(result.error!);
    final values = result.value!;
    if (values.length != DataGroupRegister.values.length) {
      return failure(ErrorCode.modbusException, '数据组响应长度无效');
    }
    return Success(_groupFromValues(index, values));
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
    try {
      final values = _groupToWritableValues(group);
      return _client.writeRegisters(
        RegisterCatalog.dataGroupBase +
            group.index * RegisterCatalog.dataGroupStride,
        values,
      );
    } on ArgumentError catch (error) {
      return failure(
        ErrorCode.invalidRegisterValue,
        error.message?.toString() ?? '数据组参数无效',
        cause: error,
      );
    }
  }

  @override
  Future<Result<void>> activateDataGroup(int index) async {
    if (!status.isConnected) return failure(ErrorCode.deviceNotReady, '设备未连接');
    if (index < 0 || index >= RegisterCatalog.dataGroupCount) {
      return failure(ErrorCode.invalidRegisterValue, '数据组编号无效');
    }
    if (status.outputState != OutputState.off) {
      return failure(ErrorCode.deviceNotReady, '仅可在输出关闭时调用数据组');
    }
    final result = await _client.writeRegister(
      PowerRegister.extractMemory.address,
      index,
    );
    if (result.isFailure) return result;
    final refreshed = await readStatus();
    return refreshed.isSuccess
        ? const Success(null)
        : Failure(refreshed.error!);
  }

  @override
  Future<Result<void>> setBuzzer(bool enabled) =>
      _client.writeRegister(PowerRegister.buzzer.address, enabled ? 1 : 0);

  @override
  Future<Result<void>> setKeyLock(bool locked) async {
    final result = await _client.writeRegister(
      PowerRegister.lock.address,
      locked ? 1 : 0,
    );
    if (result.isSuccess) emitStatus(status.copyWith(keyLocked: locked));
    return result;
  }

  @override
  Future<Result<void>> setBacklight(int level) async {
    if (level < 0 || level > 5) {
      return failure<void>(ErrorCode.invalidRegisterValue, '背光等级必须在 0-5');
    }
    final result = await _client.writeRegister(
      PowerRegister.backlight.address,
      level,
    );
    if (result.isSuccess) emitStatus(status.copyWith(backlightLevel: level));
    return result;
  }

  @override
  Future<Result<void>> setSleepMinutes(int minutes) async {
    if (minutes < 0 || minutes > 65535) {
      return failure<void>(ErrorCode.invalidRegisterValue, '息屏时间无效');
    }
    return _client.writeRegister(PowerRegister.sleep.address, minutes);
  }

  @override
  Future<Result<void>> setSlaveAddress(int address) async {
    if (address < 1 || address > 255) {
      return failure<void>(ErrorCode.invalidRegisterValue, '从机地址必须在 1-255');
    }
    final result = await _client.writeRegister(
      PowerRegister.slaveAddress.address,
      address,
    );
    if (result.isSuccess) {
      _client.slaveAddress = address;
      emitStatus(status.copyWith(slaveAddress: address));
    }
    return result;
  }

  @override
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) async {
    final result = await _client.writeRegister(
      PowerRegister.baudRate.address,
      baudRate.code,
    );
    if (result.isSuccess) {
      emitStatus(
        status.copyWith(baudRate: baudRate, baudRateRaw: baudRate.code),
      );
    }
    return result;
  }

  @override
  Future<Result<void>> setMppt({
    required bool enabled,
    int? coefficient,
  }) async {
    final switchResult = await _client.writeRegister(
      PowerRegister.mpptSwitch.address,
      enabled ? 1 : 0,
    );
    if (switchResult.isFailure || coefficient == null) return switchResult;
    return _client.writeRegister(
      PowerRegister.mpptCoefficient.address,
      coefficient,
    );
  }

  @override
  Future<Result<void>> setConstantPower({
    required bool enabled,
    required double watts,
  }) async {
    if (!watts.isFinite || watts < 0 || watts > 120) {
      return failure(ErrorCode.invalidRegisterValue, '恒功率值必须在 0-120 W');
    }
    final switchResult = await _client.writeRegister(
      PowerRegister.constantPowerSwitch.address,
      enabled ? 1 : 0,
    );
    if (switchResult.isFailure) return switchResult;
    return _client.writeRegister(
      PowerRegister.constantPower.address,
      watts.round(),
    );
  }

  @override
  Future<Result<void>> dispose() async {
    await _connectionSubscription?.cancel();
    return super.dispose();
  }

  static OutputState _outputState(int raw) => raw == 0
      ? OutputState.off
      : raw == 1
      ? OutputState.on
      : OutputState.unknown;
  static CvccState _cvccState(int raw) => raw == 0
      ? CvccState.cv
      : raw == 1
      ? CvccState.cc
      : CvccState.unknown;
  static bool? _binary(int raw) => raw == 0
      ? false
      : raw == 1
      ? true
      : null;
  static String _rawWord(int raw) =>
      '0x${raw.toRadixString(16).padLeft(4, '0').toUpperCase()}';

  static DataGroup _groupFromValues(int index, List<int> values) => DataGroup(
    index: index,
    voltageSet: values[DataGroupRegister.voltageSet.offset] / 100,
    currentSet: values[DataGroupRegister.currentSet.offset] / 1000,
    lowVoltageProtection:
        values[DataGroupRegister.lowVoltageProtection.offset] / 100,
    overVoltageProtection:
        values[DataGroupRegister.overVoltageProtection.offset] / 100,
    overCurrentProtection:
        values[DataGroupRegister.overCurrentProtection.offset] / 1000,
    overPowerProtection:
        values[DataGroupRegister.overPowerProtection.offset] / 10,
    maxOutputHours: values[DataGroupRegister.maxOutputHours.offset],
    maxOutputMinutes: values[DataGroupRegister.maxOutputMinutes.offset],
    maxOutputAh: RegisterCatalog.combineWordPair(
      high: values[DataGroupRegister.maxOutputAhHigh.offset],
      low: values[DataGroupRegister.maxOutputAhLow.offset],
    ),
    maxOutputWh: RegisterCatalog.combineWordPair(
      high: values[DataGroupRegister.maxOutputWhHigh.offset],
      low: values[DataGroupRegister.maxOutputWhLow.offset],
    ),
    overTemperatureProtection:
        values[DataGroupRegister.overTemperatureProtection.offset],
    powerOnOutput: values[DataGroupRegister.powerOnOutput.offset],
    externalTemperatureProtection:
        values[DataGroupRegister.externalTemperatureProtection.offset],
  );

  static List<int> _groupToWritableValues(DataGroup group) {
    final values = <int>[
      RegisterCatalog.encodeVoltage(group.voltageSet ?? 0),
      RegisterCatalog.encodeCurrent(group.currentSet ?? 0),
      RegisterCatalog.encodeVoltage(group.lowVoltageProtection ?? 0),
      RegisterCatalog.encodeVoltage(group.overVoltageProtection ?? 0),
      RegisterCatalog.encodeCurrent(group.overCurrentProtection ?? 0),
      ((group.overPowerProtection ?? 0) * 10).round(),
      group.maxOutputHours ?? 0,
      group.maxOutputMinutes ?? 0,
      (group.maxOutputAh ?? 0) & 0xFFFF,
      ((group.maxOutputAh ?? 0) >> 16) & 0xFFFF,
      (group.maxOutputWh ?? 0) & 0xFFFF,
      ((group.maxOutputWh ?? 0) >> 16) & 0xFFFF,
      group.overTemperatureProtection ?? 0,
      group.powerOnOutput ?? 0,
    ];
    for (final value in values) {
      if (value < 0 || value > 0xFFFF) {
        throw ArgumentError.value(value, 'group', '数据组寄存器值超出 16 位范围');
      }
    }
    return values;
  }
}
