import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/mock_power_device.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';

void main() {
  late MockPowerDevice device;

  setUp(() => device = MockPowerDevice());
  tearDown(() => device.dispose());

  test('mock device connects and keeps output state explicit', () async {
    expect(device.status.outputState, OutputState.off);
    await device.connect();
    expect(device.status.isConnected, isTrue);
    await device.setVoltage(24);
    await device.setCurrent(2);
    await device.setOutput(true);
    final status = (await device.readStatus()).value!;
    expect(status.outputState, OutputState.on);
    expect(status.outputPower, closeTo(48, 0.01));
    await device.disconnect();
    expect(device.status.outputState, OutputState.unknown);
  });

  test(
    'mock device rejects unsafe values and group writes while output is on',
    () async {
      await device.connect();
      expect((await device.setVoltage(36.1)).isFailure, isTrue);
      final group = (await device.readDataGroup(0)).value!;
      await device.setOutput(true);
      expect((await device.writeDataGroup(group)).isFailure, isTrue);
    },
  );

  test('mock settings use documented ranges and baud codes', () async {
    await device.connect();
    expect((await device.setBacklight(0)).isSuccess, isTrue);
    expect((await device.setBacklight(5)).isSuccess, isTrue);
    expect((await device.setBacklight(6)).isFailure, isTrue);
    expect((await device.setSlaveAddress(255)).isSuccess, isTrue);
    expect((await device.setSlaveAddress(256)).isFailure, isTrue);
    await device.setKeyLock(true);
    expect(device.status.keyLocked, isTrue);
    for (final rate in DeviceBaudRate.values) {
      expect((await device.setBaudRate(rate)).isSuccess, isTrue);
      expect(device.status.baudRateRaw, rate.code);
    }
  });

  test(
    'activating a group changes current settings without rewriting it',
    () async {
      await device.connect();
      final group = (await device.readDataGroup(
        9,
      )).value!.copyWith(voltageSet: 18.5, currentSet: 2.25);
      await device.writeDataGroup(group);
      await device.setVoltage(12);
      expect((await device.activateDataGroup(9)).isSuccess, isTrue);
      expect(device.status.voltageSet, 18.5);
      expect(device.status.currentSet, 2.25);
      expect((await device.activateDataGroup(-1)).isFailure, isTrue);
      expect((await device.activateDataGroup(10)).isFailure, isTrue);
      await device.setOutput(true);
      expect((await device.activateDataGroup(0)).isFailure, isTrue);
      expect((await device.readDataGroup(9)).value!.voltageSet, 18.5);
    },
  );

  test(
    'service closes an output session when output changes from on to off',
    () async {
      OutputSession? session;
      final service = PowerDeviceService(
        device,
        onSession: (value) => session = value,
      );
      await service.connect();
      await service.setOutput(true);
      await device.readStatus();
      await service.setOutput(false);
      await Future<void>.delayed(Duration.zero);
      expect(session, isNotNull);
      expect(session!.deviceId, 'mock-sk120');
      expect(session!.endTime, isNotNull);
      await service.dispose();
    },
  );
}
