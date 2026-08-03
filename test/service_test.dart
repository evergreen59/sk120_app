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
