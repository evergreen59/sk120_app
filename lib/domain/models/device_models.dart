import '../protocol/registers.dart';

enum DeviceMode { real, mock }

enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  reconnecting,
  error,
}

enum OutputState { on, off, unknown }

enum CvccState { cv, cc, unknown }

enum TemperatureUnit { celsius, fahrenheit }

enum ProtectionStatus {
  normal(0, '正常', 'NORMAL'),
  overVoltage(1, '过压保护', 'OVP'),
  overCurrent(2, '过流保护', 'OCP'),
  overPower(3, '过功率保护', 'OPP'),
  lowInputVoltage(4, '输入低压保护', 'LVP'),
  maxOutputCapacity(5, '最大输出容量保护', 'OAH'),
  maxOutputTime(6, '最大输出时间保护', 'OHP'),
  overTemperature(7, '过温保护', 'OTP'),
  noOutput(8, '无输出保护', 'OEP'),
  maxOutputEnergy(9, '最大输出能量保护', 'OWH'),
  maxInputCurrent(10, '最大输入电流保护', 'ICP'),
  externalTemperature(11, '外部温度保护', 'ETP');

  const ProtectionStatus(this.code, this.label, this.abbreviation);

  final int code;
  final String label;
  final String abbreviation;

  String get displayLabel => '$label ($abbreviation)';

  static ProtectionStatus? fromCode(int code) {
    for (final status in values) {
      if (status.code == code) return status;
    }
    return null;
  }
}

enum DeviceBaudRate {
  baud9600(0, 9600),
  baud14400(1, 14400),
  baud19200(2, 19200),
  baud38400(3, 38400),
  baud56000(4, 56000),
  baud57600(5, 57600),
  baud115200(6, 115200),
  baud2400(7, 2400, partiallySupported: true),
  baud4800(8, 4800, partiallySupported: true);

  const DeviceBaudRate(
    this.code,
    this.bitsPerSecond, {
    this.partiallySupported = false,
  });

  final int code;
  final int bitsPerSecond;
  final bool partiallySupported;

  String get label =>
      partiallySupported ? '$bitsPerSecond（部分设备）' : '$bitsPerSecond';

  static DeviceBaudRate? fromCode(int code) {
    for (final rate in values) {
      if (rate.code == code) return rate;
    }
    return null;
  }
}

class BleDeviceInfo {
  const BleDeviceInfo({
    required this.id,
    required this.name,
    this.rssi,
    this.serviceUuids = const [],
  });

  final String id;
  final String name;
  final int? rssi;
  final List<String> serviceUuids;
}

class DeviceStatus {
  const DeviceStatus({
    this.connectionState = DeviceConnectionState.disconnected,
    this.outputState = OutputState.unknown,
    this.cvccState = CvccState.unknown,
    this.protectionStatus,
    this.protectionRaw,
    this.keyLocked,
    this.buzzerEnabled,
    this.backlightLevel,
    this.voltageSet,
    this.currentSet,
    this.outputVoltage,
    this.outputCurrent,
    this.outputPower,
    this.inputVoltage,
    this.outputAh,
    this.outputWh,
    this.outputDuration = Duration.zero,
    this.internalTemperature,
    this.externalTemperature,
    this.model,
    this.firmwareVersion,
    this.slaveAddress = 1,
    this.baudRate,
    this.baudRateRaw,
    this.mpptEnabled,
    this.mpptCoefficient,
    this.constantPowerEnabled,
    this.constantPowerValue,
    this.lastUpdated,
  });

  final DeviceConnectionState connectionState;
  final OutputState outputState;
  final CvccState cvccState;
  final ProtectionStatus? protectionStatus;
  final int? protectionRaw;
  final bool? keyLocked;
  final bool? buzzerEnabled;
  final int? backlightLevel;
  final double? voltageSet;
  final double? currentSet;
  final double? outputVoltage;
  final double? outputCurrent;
  final double? outputPower;
  final double? inputVoltage;
  final int? outputAh;
  final int? outputWh;
  final Duration outputDuration;
  final double? internalTemperature;
  final double? externalTemperature;
  final String? model;
  final String? firmwareVersion;
  final int slaveAddress;
  final DeviceBaudRate? baudRate;
  final int? baudRateRaw;
  final bool? mpptEnabled;
  final int? mpptCoefficient;
  final bool? constantPowerEnabled;
  final double? constantPowerValue;
  final DateTime? lastUpdated;

  bool get isConnected => connectionState == DeviceConnectionState.connected;
  bool get protectionKnown => protectionStatus != null;
  String get protectionLabel {
    final decoded = protectionStatus;
    if (decoded != null) return decoded.displayLabel;
    final raw = protectionRaw;
    return raw == null ? '未知' : '未知（原始码 $raw）';
  }

  String get baudRateLabel {
    final decoded = baudRate;
    if (decoded != null) return decoded.label;
    final raw = baudRateRaw;
    return raw == null ? '未知' : '未知代码 $raw';
  }

  DeviceStatus copyWith({
    DeviceConnectionState? connectionState,
    OutputState? outputState,
    CvccState? cvccState,
    ProtectionStatus? protectionStatus,
    int? protectionRaw,
    bool? keyLocked,
    bool? buzzerEnabled,
    int? backlightLevel,
    double? voltageSet,
    double? currentSet,
    double? outputVoltage,
    double? outputCurrent,
    double? outputPower,
    double? inputVoltage,
    int? outputAh,
    int? outputWh,
    Duration? outputDuration,
    double? internalTemperature,
    double? externalTemperature,
    String? model,
    String? firmwareVersion,
    int? slaveAddress,
    DeviceBaudRate? baudRate,
    int? baudRateRaw,
    bool? mpptEnabled,
    int? mpptCoefficient,
    bool? constantPowerEnabled,
    double? constantPowerValue,
    DateTime? lastUpdated,
  }) {
    return DeviceStatus(
      connectionState: connectionState ?? this.connectionState,
      outputState: outputState ?? this.outputState,
      cvccState: cvccState ?? this.cvccState,
      protectionStatus: protectionStatus ?? this.protectionStatus,
      protectionRaw: protectionRaw ?? this.protectionRaw,
      keyLocked: keyLocked ?? this.keyLocked,
      buzzerEnabled: buzzerEnabled ?? this.buzzerEnabled,
      backlightLevel: backlightLevel ?? this.backlightLevel,
      voltageSet: voltageSet ?? this.voltageSet,
      currentSet: currentSet ?? this.currentSet,
      outputVoltage: outputVoltage ?? this.outputVoltage,
      outputCurrent: outputCurrent ?? this.outputCurrent,
      outputPower: outputPower ?? this.outputPower,
      inputVoltage: inputVoltage ?? this.inputVoltage,
      outputAh: outputAh ?? this.outputAh,
      outputWh: outputWh ?? this.outputWh,
      outputDuration: outputDuration ?? this.outputDuration,
      internalTemperature: internalTemperature ?? this.internalTemperature,
      externalTemperature: externalTemperature ?? this.externalTemperature,
      model: model ?? this.model,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      slaveAddress: slaveAddress ?? this.slaveAddress,
      baudRate: baudRate ?? this.baudRate,
      baudRateRaw: baudRateRaw ?? this.baudRateRaw,
      mpptEnabled: mpptEnabled ?? this.mpptEnabled,
      mpptCoefficient: mpptCoefficient ?? this.mpptCoefficient,
      constantPowerEnabled: constantPowerEnabled ?? this.constantPowerEnabled,
      constantPowerValue: constantPowerValue ?? this.constantPowerValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class DataGroup {
  const DataGroup({
    required this.index,
    this.name,
    this.voltageSet,
    this.currentSet,
    this.lowVoltageProtection,
    this.overVoltageProtection,
    this.overCurrentProtection,
    this.overPowerProtection,
    this.maxOutputHours,
    this.maxOutputMinutes,
    this.maxOutputAh,
    this.maxOutputWh,
    this.overTemperatureProtection,
    this.powerOnOutput,
    this.externalTemperatureProtection,
  });

  final int index;
  final String? name;
  final double? voltageSet;
  final double? currentSet;
  final double? lowVoltageProtection;
  final double? overVoltageProtection;
  final double? overCurrentProtection;
  final double? overPowerProtection;
  final int? maxOutputHours;
  final int? maxOutputMinutes;
  final int? maxOutputAh;
  final int? maxOutputWh;
  final int? overTemperatureProtection;
  final int? powerOnOutput;
  final int? externalTemperatureProtection;

  int get baseAddress =>
      RegisterCatalog.dataGroupBase + index * RegisterCatalog.dataGroupStride;
  bool get isValidIndex => index >= 0 && index < RegisterCatalog.dataGroupCount;

  DataGroup copyWith({
    String? name,
    double? voltageSet,
    double? currentSet,
    double? lowVoltageProtection,
    double? overVoltageProtection,
    double? overCurrentProtection,
    double? overPowerProtection,
    int? maxOutputHours,
    int? maxOutputMinutes,
    int? maxOutputAh,
    int? maxOutputWh,
    int? overTemperatureProtection,
    int? powerOnOutput,
    int? externalTemperatureProtection,
  }) => DataGroup(
    index: index,
    name: name ?? this.name,
    voltageSet: voltageSet ?? this.voltageSet,
    currentSet: currentSet ?? this.currentSet,
    lowVoltageProtection: lowVoltageProtection ?? this.lowVoltageProtection,
    overVoltageProtection: overVoltageProtection ?? this.overVoltageProtection,
    overCurrentProtection: overCurrentProtection ?? this.overCurrentProtection,
    overPowerProtection: overPowerProtection ?? this.overPowerProtection,
    maxOutputHours: maxOutputHours ?? this.maxOutputHours,
    maxOutputMinutes: maxOutputMinutes ?? this.maxOutputMinutes,
    maxOutputAh: maxOutputAh ?? this.maxOutputAh,
    maxOutputWh: maxOutputWh ?? this.maxOutputWh,
    overTemperatureProtection:
        overTemperatureProtection ?? this.overTemperatureProtection,
    powerOnOutput: powerOnOutput ?? this.powerOnOutput,
    externalTemperatureProtection:
        externalTemperatureProtection ?? this.externalTemperatureProtection,
  );
}

class Preset {
  const Preset({
    this.id,
    required this.name,
    required this.voltage,
    required this.current,
  });

  final int? id;
  final String name;
  final double voltage;
  final double current;
}

class MeasurementSample {
  const MeasurementSample({
    required this.deviceId,
    required this.timestamp,
    this.voltage,
    this.current,
    this.power,
    this.temperature,
    this.inputVoltage,
    this.ah,
    this.wh,
    this.outputState = OutputState.unknown,
  });

  final String deviceId;
  final DateTime timestamp;
  final double? voltage;
  final double? current;
  final double? power;
  final double? temperature;
  final double? inputVoltage;
  final int? ah;
  final int? wh;
  final OutputState outputState;
}

class OutputSession {
  const OutputSession({
    this.id,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    this.outputDuration = Duration.zero,
    this.averageVoltage,
    this.averageCurrent,
    this.maxPower,
    this.totalAh,
    this.totalWh,
  });

  final int? id;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration outputDuration;
  final double? averageVoltage;
  final double? averageCurrent;
  final double? maxPower;
  final int? totalAh;
  final int? totalWh;
}

enum CommunicationDirection { tx, rx }

class CommunicationLogEntry {
  const CommunicationLogEntry({
    this.id,
    required this.deviceId,
    required this.timestamp,
    required this.direction,
    required this.rawBytes,
    this.parsedMessage,
    required this.success,
    this.error,
  });

  final int? id;
  final String deviceId;
  final DateTime timestamp;
  final CommunicationDirection direction;
  final List<int> rawBytes;
  final String? parsedMessage;
  final bool success;
  final String? error;
}

class ProtectionSettings {
  const ProtectionSettings({
    this.lowVoltage,
    this.overVoltage,
    this.overCurrent,
    this.overPower,
    this.overTemperature,
    this.maxHours,
    this.maxMinutes,
    this.maxAh,
    this.maxWh,
    this.externalTemperatureProtection,
    this.powerOnOutput,
  });

  final double? lowVoltage;
  final double? overVoltage;
  final double? overCurrent;
  final double? overPower;
  final int? overTemperature;
  final int? maxHours;
  final int? maxMinutes;
  final int? maxAh;
  final int? maxWh;
  final int? externalTemperatureProtection;
  final int? powerOnOutput;
}
