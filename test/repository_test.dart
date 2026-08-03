import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/data/database/app_database.dart'
    hide MeasurementSample, OutputSession, Preset;
import 'package:xy_sk120_control/data/repositories/app_repository.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';

void main() {
  late Sk120Database database;
  late AppRepository repository;

  setUp(() {
    database = Sk120Database.memory();
    repository = AppRepository(database);
  });

  tearDown(() => database.close());

  test('persists presets, groups, samples and sessions', () async {
    await repository.savePreset(
      const Preset(name: '12V / 1A', voltage: 12, current: 1),
    );
    expect((await repository.loadPresets()).single.name, '12V / 1A');

    final group = const DataGroup(
      index: 3,
      name: 'Bench',
      voltageSet: 24,
      currentSet: 1.5,
      overPowerProtection: 36,
    );
    await repository.saveGroup(group, deviceId: 'device-1');
    expect((await repository.loadGroups('device-1')).single.name, 'Bench');

    await repository.saveSample(
      MeasurementSample(
        deviceId: 'device-1',
        timestamp: DateTime(2026, 1, 1),
        voltage: 24,
        current: 1.5,
        power: 36,
        outputState: OutputState.on,
      ),
    );
    await repository.saveSession(
      OutputSession(
        deviceId: 'device-1',
        startTime: DateTime(2026, 1, 1),
        endTime: DateTime(2026, 1, 1, 0, 1),
        outputDuration: const Duration(minutes: 1),
        averageVoltage: 24,
        averageCurrent: 1.5,
        maxPower: 36,
        totalAh: 25,
        totalWh: 600,
      ),
    );
    expect((await repository.loadSessions('device-1')).single.maxPower, 36);
  });

  test('round trips communication logs and exports', () async {
    await repository.saveCommunicationLog(
      CommunicationLogEntry(
        deviceId: 'device-1',
        timestamp: DateTime(2026, 1, 1),
        direction: CommunicationDirection.tx,
        rawBytes: const [1, 3, 0, 0],
        parsedMessage: 'read',
        success: true,
      ),
    );
    final logs = await repository.loadCommunicationLogs('device-1');
    expect(logs.single.rawBytes, [1, 3, 0, 0]);
    expect(await repository.exportLogsCsv('device-1'), contains('device_id'));
    expect(
      await repository.exportLogsJson('device-1'),
      contains('"direction":"tx"'),
    );
  });

  test('persists and updates app settings used by favorite devices', () async {
    await repository.setSetting(
      'favorite_ble_device_ids',
      '["98:EA:A0:00:4F:39"]',
    );
    expect(
      await repository.getSetting('favorite_ble_device_ids'),
      '["98:EA:A0:00:4F:39"]',
    );

    await repository.setSetting('favorite_ble_device_ids', '[]');
    expect(await repository.getSetting('favorite_ble_device_ids'), '[]');
  });
}
