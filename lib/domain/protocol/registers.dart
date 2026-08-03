import 'dart:math' as math;

enum RegisterAccess { readOnly, readWrite }

enum RegisterSafety { normal, protected, engineeringOnly }

class RegisterDefinition {
  const RegisterDefinition({
    required this.address,
    required this.name,
    required this.label,
    required this.scale,
    required this.unit,
    required this.access,
    this.safety = RegisterSafety.normal,
    this.description,
  });

  final int address;
  final String name;
  final String label;
  final int scale;
  final String unit;
  final RegisterAccess access;
  final RegisterSafety safety;
  final String? description;

  bool get writable =>
      access == RegisterAccess.readWrite &&
      safety != RegisterSafety.engineeringOnly;
  double decode(int raw) => raw / math.pow(10, scale);
  int encode(double value) => (value * math.pow(10, scale)).round();
}

enum PowerRegister {
  voltageSet(
    RegisterDefinition(
      address: 0x0000,
      name: 'V-SET',
      label: '电压设定',
      scale: 2,
      unit: 'V',
      access: RegisterAccess.readWrite,
    ),
  ),
  currentSet(
    RegisterDefinition(
      address: 0x0001,
      name: 'I-SET',
      label: '电流设定',
      scale: 3,
      unit: 'A',
      access: RegisterAccess.readWrite,
    ),
  ),
  outputVoltage(
    RegisterDefinition(
      address: 0x0002,
      name: 'VOUT',
      label: '输出电压',
      scale: 2,
      unit: 'V',
      access: RegisterAccess.readOnly,
    ),
  ),
  outputCurrent(
    RegisterDefinition(
      address: 0x0003,
      name: 'IOUT',
      label: '输出电流',
      scale: 3,
      unit: 'A',
      access: RegisterAccess.readOnly,
    ),
  ),
  outputPower(
    RegisterDefinition(
      address: 0x0004,
      name: 'POWER',
      label: '输出功率',
      scale: 2,
      unit: 'W',
      access: RegisterAccess.readOnly,
    ),
  ),
  inputVoltage(
    RegisterDefinition(
      address: 0x0005,
      name: 'UIN',
      label: '输入电压',
      scale: 2,
      unit: 'V',
      access: RegisterAccess.readOnly,
    ),
  ),
  ahLow(
    RegisterDefinition(
      address: 0x0006,
      name: 'AH-LOW',
      label: '输出 AH 低 16 位',
      scale: 0,
      unit: 'mAh',
      access: RegisterAccess.readOnly,
    ),
  ),
  ahHigh(
    RegisterDefinition(
      address: 0x0007,
      name: 'AH-HIGH',
      label: '输出 AH 高 16 位',
      scale: 0,
      unit: 'mAh',
      access: RegisterAccess.readOnly,
    ),
  ),
  whLow(
    RegisterDefinition(
      address: 0x0008,
      name: 'WH-LOW',
      label: '输出 WH 低 16 位',
      scale: 0,
      unit: 'mWh',
      access: RegisterAccess.readOnly,
    ),
  ),
  whHigh(
    RegisterDefinition(
      address: 0x0009,
      name: 'WH-HIGH',
      label: '输出 WH 高 16 位',
      scale: 0,
      unit: 'mWh',
      access: RegisterAccess.readOnly,
    ),
  ),
  outputHours(
    RegisterDefinition(
      address: 0x000A,
      name: 'OUT_H',
      label: '输出时长-小时',
      scale: 0,
      unit: 'h',
      access: RegisterAccess.readOnly,
    ),
  ),
  outputMinutes(
    RegisterDefinition(
      address: 0x000B,
      name: 'OUT_M',
      label: '输出时长-分钟',
      scale: 0,
      unit: 'min',
      access: RegisterAccess.readOnly,
    ),
  ),
  outputSeconds(
    RegisterDefinition(
      address: 0x000C,
      name: 'OUT_S',
      label: '输出时长-秒',
      scale: 0,
      unit: 's',
      access: RegisterAccess.readOnly,
    ),
  ),
  internalTemperature(
    RegisterDefinition(
      address: 0x000D,
      name: 'T_IN',
      label: '内部温度',
      scale: 1,
      unit: 'F/C',
      access: RegisterAccess.readOnly,
    ),
  ),
  externalTemperature(
    RegisterDefinition(
      address: 0x000E,
      name: 'T_EX',
      label: '外部温度',
      scale: 1,
      unit: 'F/C',
      access: RegisterAccess.readOnly,
    ),
  ),
  lock(
    RegisterDefinition(
      address: 0x000F,
      name: 'LOCK',
      label: '按键锁',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  protect(
    RegisterDefinition(
      address: 0x0010,
      name: 'PROTECT',
      label: '保护原始状态',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  cvcc(
    RegisterDefinition(
      address: 0x0011,
      name: 'CVCC',
      label: '恒压恒流状态',
      scale: 0,
      unit: '',
      access: RegisterAccess.readOnly,
    ),
  ),
  output(
    RegisterDefinition(
      address: 0x0012,
      name: 'ONOFF',
      label: '输出开关',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  temperatureSign(
    RegisterDefinition(
      address: 0x0013,
      name: 'F-C',
      label: '温度符号原始值',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  backlight(
    RegisterDefinition(
      address: 0x0014,
      name: 'B-LED',
      label: '背光亮度',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  sleep(
    RegisterDefinition(
      address: 0x0015,
      name: 'SLEEP',
      label: '息屏时间',
      scale: 0,
      unit: 'min',
      access: RegisterAccess.readWrite,
    ),
  ),
  model(
    RegisterDefinition(
      address: 0x0016,
      name: 'MODEL',
      label: '产品型号',
      scale: 0,
      unit: '',
      access: RegisterAccess.readOnly,
    ),
  ),
  version(
    RegisterDefinition(
      address: 0x0017,
      name: 'VERSION',
      label: '固件版本',
      scale: 0,
      unit: '',
      access: RegisterAccess.readOnly,
    ),
  ),
  slaveAddress(
    RegisterDefinition(
      address: 0x0018,
      name: 'SLAVE-ADD',
      label: '从机地址',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  baudRate(
    RegisterDefinition(
      address: 0x0019,
      name: 'BAUDRATE_L',
      label: '波特率',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  internalTemperatureOffset(
    RegisterDefinition(
      address: 0x001A,
      name: 'T-IN-OFFSET',
      label: '内部温度修正',
      scale: 1,
      unit: 'F/C',
      access: RegisterAccess.readWrite,
    ),
  ),
  externalTemperatureOffset(
    RegisterDefinition(
      address: 0x001B,
      name: 'T-EX-OFFSET',
      label: '外部温度修正',
      scale: 1,
      unit: 'F/C',
      access: RegisterAccess.readWrite,
    ),
  ),
  buzzer(
    RegisterDefinition(
      address: 0x001C,
      name: 'BUZZER',
      label: '蜂鸣器',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  extractMemory(
    RegisterDefinition(
      address: 0x001D,
      name: 'EXTRACT-M',
      label: '快捷调出数据组',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  deviceState(
    RegisterDefinition(
      address: 0x001E,
      name: 'DEVICE',
      label: '设备状态',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  mpptSwitch(
    RegisterDefinition(
      address: 0x001F,
      name: 'MPPT-SW',
      label: 'MPPT 开关',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  mpptCoefficient(
    RegisterDefinition(
      address: 0x0020,
      name: 'MPPT-K',
      label: 'MPPT 系数',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  batteryFullCurrent(
    RegisterDefinition(
      address: 0x0021,
      name: 'BatFul',
      label: '满电截至电流',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  constantPowerSwitch(
    RegisterDefinition(
      address: 0x0022,
      name: 'CW-SW',
      label: '恒功率开关',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  constantPower(
    RegisterDefinition(
      address: 0x0023,
      name: 'CW',
      label: '恒功率值',
      scale: 0,
      unit: 'W',
      access: RegisterAccess.readWrite,
    ),
  ),
  master(
    RegisterDefinition(
      address: 0x0030,
      name: 'MASTER',
      label: '主机类型',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  wifiConfig(
    RegisterDefinition(
      address: 0x0031,
      name: 'WIFI-CONFIG',
      label: 'WIFI 配网',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  wifiStatus(
    RegisterDefinition(
      address: 0x0032,
      name: 'WIFI-STATUS',
      label: 'WIFI 状态',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  ipv4High(
    RegisterDefinition(
      address: 0x0033,
      name: 'IPV4-H',
      label: 'IP 地址前两字节',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  ),
  ipv4Low(
    RegisterDefinition(
      address: 0x0034,
      name: 'IPV4-L',
      label: 'IP 地址后两字节',
      scale: 0,
      unit: '',
      access: RegisterAccess.readWrite,
    ),
  );

  const PowerRegister(this.definition);

  final RegisterDefinition definition;
  int get address => definition.address;
  String get label => definition.label;
  int get scale => definition.scale;
  String get unit => definition.unit;
  RegisterAccess get access => definition.access;
}

enum DataGroupRegister {
  voltageSet('V-SET', '电压设定', 0, 2, 'V'),
  currentSet('I-SET', '电流设定', 1, 3, 'A'),
  lowVoltageProtection('S-LVP', '低压保护', 2, 2, 'V'),
  overVoltageProtection('S-OVP', '过压保护', 3, 2, 'V'),
  overCurrentProtection('S-OCP', '过流保护', 4, 3, 'A'),
  overPowerProtection('S-OPP', '过功率保护', 5, 1, 'W'),
  maxOutputHours('S-OHP_H', '最大输出时长-小时', 6, 0, 'h'),
  maxOutputMinutes('S-OHP_M', '最大输出时长-分钟', 7, 0, 'min'),
  maxOutputAhLow('S-OAH_L', '最大输出 AH 低 16 位', 8, 0, 'mAh'),
  maxOutputAhHigh('S-OAH_H', '最大输出 AH 高 16 位', 9, 0, 'mAh'),
  maxOutputWhLow('S-OWH_L', '最大输出 WH 低 16 位', 10, 0, '10mWh'),
  maxOutputWhHigh('S-OWH_H', '最大输出 WH 高 16 位', 11, 0, '10mWh'),
  overTemperatureProtection('S-OTP', '过温保护', 12, 0, 'F/C'),
  powerOnOutput('S-INI', '上电输出', 13, 0, ''),
  externalTemperatureProtection('S-ETP', '外部过温保护', 14, 0, '');

  const DataGroupRegister(
    this.name,
    this.label,
    this.offset,
    this.scale,
    this.unit,
  );

  final String name;
  final String label;
  final int offset;
  final int scale;
  final String unit;
}

abstract final class RegisterCatalog {
  static const int dataGroupBase = 0x0050;
  static const int dataGroupStride = 0x0010;
  static const int dataGroupCount = 10;
  static const int dataGroupWriteEnd = 0x005D;

  static int dataGroupAddress(int groupIndex, DataGroupRegister register) {
    if (groupIndex < 0 || groupIndex >= dataGroupCount) {
      throw RangeError.range(groupIndex, 0, dataGroupCount - 1, 'groupIndex');
    }
    return dataGroupBase + groupIndex * dataGroupStride + register.offset;
  }

  static bool isEngineeringAddress(int address) =>
      (address >= 0x0400 && address <= 0x040B) ||
      (address >= 0x1000 && address <= 0x100E) ||
      (address >= 0x1500 && address <= 0x1506);

  static const int maxVoltageRaw = 3600;
  static const int maxCurrentRaw = 5000;
  static const int maxPowerRaw = 12000;

  static int encodeVoltage(double volts) =>
      _encodeBounded(volts, 0, 36, 2, '电压');
  static int encodeCurrent(double amps) => _encodeBounded(amps, 0, 5, 3, '电流');
  static int encodePower(double watts) =>
      _encodeBounded(watts, 0, 120, 2, '功率');

  static double decodeVoltage(int raw) => raw / 100;
  static double decodeCurrent(int raw) => raw / 1000;
  static double decodePower(int raw) => raw / 100;

  static int _encodeBounded(
    double value,
    double min,
    double max,
    int scale,
    String name,
  ) {
    if (!value.isFinite || value < min || value > max) {
      throw ArgumentError.value(value, name, '必须在 $min-$max 范围内');
    }
    return (value * math.pow(10, scale)).round();
  }

  static int combineWordPair({required int high, required int low}) =>
      (high << 16) | (low & 0xFFFF);

  static Duration outputDuration({
    required int hours,
    required int minutes,
    required int seconds,
  }) => Duration(hours: hours, minutes: minutes, seconds: seconds);
}
