import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/domain/protocol/registers.dart';

void main() {
  test('encodes and validates the fixed safe ranges', () {
    expect(RegisterCatalog.encodeVoltage(36), 3600);
    expect(RegisterCatalog.encodeCurrent(5), 5000);
    expect(RegisterCatalog.encodePower(120), 12000);
    expect(() => RegisterCatalog.encodeVoltage(36.01), throwsArgumentError);
    expect(() => RegisterCatalog.encodeCurrent(-0.01), throwsArgumentError);
    expect(() => RegisterCatalog.encodePower(double.nan), throwsArgumentError);
  });

  test('computes all M0-M9 addresses without business literals', () {
    expect(
      RegisterCatalog.dataGroupAddress(0, DataGroupRegister.voltageSet),
      0x0050,
    );
    expect(
      RegisterCatalog.dataGroupAddress(3, DataGroupRegister.currentSet),
      0x0081,
    );
    expect(
      RegisterCatalog.dataGroupAddress(
        9,
        DataGroupRegister.externalTemperatureProtection,
      ),
      0x00EE,
    );
    expect(
      () => RegisterCatalog.dataGroupAddress(10, DataGroupRegister.voltageSet),
      throwsRangeError,
    );
  });

  test('combines AH/WH word pairs and output duration', () {
    expect(
      RegisterCatalog.combineWordPair(high: 0x1234, low: 0xABCD),
      0x1234ABCD,
    );
    expect(
      RegisterCatalog.outputDuration(hours: 1, minutes: 2, seconds: 3),
      const Duration(hours: 1, minutes: 2, seconds: 3),
    );
  });

  test('marks calibration and OZONE regions as engineering-only', () {
    expect(RegisterCatalog.isEngineeringAddress(0x0400), isTrue);
    expect(RegisterCatalog.isEngineeringAddress(0x100E), isTrue);
    expect(RegisterCatalog.isEngineeringAddress(0x1506), isTrue);
    expect(RegisterCatalog.isEngineeringAddress(0x0050), isFalse);
  });
}
