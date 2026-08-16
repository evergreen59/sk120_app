import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/app/theme/app_theme.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/core/errors/app_error.dart';
import 'package:xy_sk120_control/core/result/result.dart';
import 'package:xy_sk120_control/data/repositories/in_memory_repository.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/device_polling_service.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';
import 'package:xy_sk120_control/shared/widgets/metric_card.dart';

import 'support/test_power_device.dart';

void main() {
  group('core result and errors', () {
    test('exposes and folds success and failure values', () {
      const Result<int> success = Success(7);
      const Result<int> failure = Failure(
        AppError(code: ErrorCode.cancelled, message: 'cancelled'),
      );
      expect(success.value, 7);
      expect(success.error, isNull);
      expect(success.fold(onSuccess: (v) => v * 2, onFailure: (_) => 0), 14);
      expect(failure.value, isNull);
      expect(failure.error?.code, ErrorCode.cancelled);
      expect(failure.fold(onSuccess: (v) => v, onFailure: (_) => -1), -1);
    });

    test('formats detailed and Modbus errors', () {
      const detailed = AppError(
        code: ErrorCode.unknown,
        message: 'failed',
        details: 'detail',
      );
      expect(detailed.toString(), 'failed (detail)');
      final modbus = ModbusExceptionError(functionCode: 3, exceptionCode: 2);
      expect(modbus.toString(), contains('功能码 0x3'));
      expect(modbus.exceptionCode, 2);
    });
  });

  test('in-memory repository covers isolation, ordering and exports', () async {
    final repository = InMemoryRepository();
    await repository.savePreset(
      const Preset(name: 'default', voltage: 12, current: 1),
      deviceId: 'a',
    );
    await repository.savePreset(
      const Preset(id: 99, name: 'explicit', voltage: 24, current: 2),
    );
    expect((await repository.loadPresets()).map((p) => p.id), [1, 99]);

    const first = DataGroup(index: 1, name: 'one', voltageSet: 12);
    await repository.saveGroup(first, deviceId: 'a');
    await repository.saveGroup(first.copyWith(name: 'updated'), deviceId: 'a');
    await repository.saveGroup(first, deviceId: 'b');
    expect((await repository.loadGroups('a')).single.name, 'updated');
    expect((await repository.loadGroups('b')).single.name, 'one');

    final older = OutputSession(
      deviceId: 'a,quoted',
      startTime: DateTime(2026, 1, 1),
      outputDuration: const Duration(seconds: 4),
    );
    final newer = OutputSession(
      deviceId: 'a,quoted',
      startTime: DateTime(2026, 1, 2),
      endTime: DateTime(2026, 1, 2, 0, 1),
      outputDuration: const Duration(minutes: 1),
      averageVoltage: 12,
      averageCurrent: 1,
      maxPower: 12,
      totalAh: 3,
      totalWh: 4,
    );
    await repository.saveSample(
      MeasurementSample(deviceId: 'a', timestamp: DateTime(2026)),
    );
    await repository.saveSession(older);
    await repository.saveSession(newer);
    expect(
      (await repository.loadSessions('a,quoted')).first.startTime,
      newer.startTime,
    );
    expect(
      await repository.exportSessionsCsv('a,quoted'),
      contains('"a,quoted"'),
    );
    expect(
      jsonDecode(await repository.exportSessionsJson('a,quoted')),
      isA<List<dynamic>>(),
    );

    await repository.saveCommunicationLog(
      CommunicationLogEntry(
        deviceId: 'a',
        timestamp: DateTime(2026),
        direction: CommunicationDirection.rx,
        rawBytes: const [0, 15, 255],
        parsedMessage: 'comma,"quote"\nline',
        success: false,
        error: 'bad',
      ),
    );
    expect(await repository.exportLogsCsv('a'), contains('00 0F FF'));
    expect(await repository.exportLogsCsv('a'), contains('""quote""'));
    expect(await repository.exportLogsJson('a'), contains('"rx"'));
    await repository.setSetting('key', 'one');
    await repository.setSetting('key', 'two');
    expect(await repository.getSetting('key'), 'two');
    expect(await repository.getSetting('missing'), isNull);
  });

  group('device polling and service', () {
    testWidgets('polling is idempotent, samples success and skips failures', (
      tester,
    ) async {
      final device = TestPowerDevice(
        status: const DeviceStatus(
          connectionState: DeviceConnectionState.connected,
          outputState: OutputState.on,
          outputVoltage: 12,
          outputCurrent: 2,
          outputPower: 24,
          inputVoltage: 25,
          internalTemperature: 30,
          outputAh: 4,
          outputWh: 5,
        ),
      );
      final samples = <MeasurementSample>[];
      final polling = DevicePollingService(
        device: device,
        interval: const Duration(milliseconds: 10),
        sampleInterval: Duration.zero,
        onSample: samples.add,
      );
      await polling.start();
      await polling.start();
      expect(polling.isRunning, isTrue);
      expect(device.readCount, 1);
      await tester.pump(const Duration(milliseconds: 11));
      expect(samples, hasLength(1));
      expect(samples.single.power, 24);

      device.readResult = const Failure(
        AppError(code: ErrorCode.modbusTimeout, message: 'timeout'),
      );
      await tester.pump(const Duration(milliseconds: 11));
      expect(samples, hasLength(1));
      device.publish(
        device.status.copyWith(
          connectionState: DeviceConnectionState.disconnected,
        ),
      );
      await tester.pump(const Duration(milliseconds: 11));
      expect(device.readCount, 3);
      await polling.stop();
      expect(polling.isRunning, isFalse);
      await tester.pump(const Duration(milliseconds: 20));
      expect(device.readCount, 3);
      await polling.dispose();
      await device.dispose();
    });

    testWidgets('service aggregates samples and retries real disconnections', (
      tester,
    ) async {
      final device = TestPowerDevice(
        status: const DeviceStatus(
          connectionState: DeviceConnectionState.disconnected,
          outputState: OutputState.off,
          outputVoltage: 10,
          outputCurrent: 2,
          outputPower: 20,
          outputAh: 7,
          outputWh: 8,
        ),
      );
      OutputSession? session;
      final samples = <MeasurementSample>[];
      final service = PowerDeviceService(
        device,
        onSample: samples.add,
        onSession: (value) => session = value,
      );
      await service.connect(deviceId: 'ble-id');
      await service.setOutput(true);
      await tester.pump(const Duration(milliseconds: 760));
      expect(samples, isNotEmpty);
      await service.setOutput(false);
      await tester.pump();
      expect(session?.averageVoltage, 10);
      expect(session?.averageCurrent, 2);
      expect(session?.maxPower, 20);
      expect(session?.totalAh, 7);

      device.connectResults.addAll([
        const Failure(
          AppError(code: ErrorCode.bleError, message: 'first retry'),
        ),
        const Success(null),
      ]);
      device.publish(
        device.status.copyWith(
          connectionState: DeviceConnectionState.disconnected,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(
        device.calls.where((call) => call.startsWith('connect:ble-id')),
        hasLength(3),
      );
      await service.disconnect();
      await service.stopReconnect();
    });
  });

  group('device state provider', () {
    test('restores and persists favorites and manages scan results', () async {
      final repository = InMemoryRepository();
      await repository.setSetting('favorite_ble_device_ids', '["b"]');
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      final container = ProviderContainer.test(
        overrides: [
          powerDeviceServiceProvider.overrideWithValue(service),
          localRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(service.dispose);
      container.read(deviceStateProvider);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(deviceStateProvider).favoriteDeviceIds, {'b'});

      final notifier = container.read(deviceStateProvider.notifier);
      await notifier.startScan();
      device.scanController.add(
        const BleDeviceInfo(id: 'a', name: 'Alpha', rssi: -20),
      );
      device.scanController.add(
        const BleDeviceInfo(id: 'b', name: 'Beta', rssi: -80),
      );
      device.scanController.add(
        const BleDeviceInfo(id: 'a', name: 'Alpha 2', rssi: -10),
      );
      await Future<void>.delayed(Duration.zero);
      final state = container.read(deviceStateProvider);
      expect(state.discoveredDevices, hasLength(2));
      expect(state.discoveredDevices.first.id, 'b');
      expect(state.discoveredDevices.last.name, 'Alpha 2');

      await notifier.toggleFavoriteDevice('a');
      expect(container.read(deviceStateProvider).favoriteDeviceIds, {'a', 'b'});
      expect(
        jsonDecode((await repository.getSetting('favorite_ble_device_ids'))!),
        ['a', 'b'],
      );
      await notifier.stopScan();
      expect(container.read(deviceStateProvider).scanning, isFalse);
    });

    test(
      'propagates operation and group failures then clears errors',
      () async {
        final repository = InMemoryRepository();
        final device = TestPowerDevice();
        final service = PowerDeviceService(device);
        final container = ProviderContainer.test(
          overrides: [
            powerDeviceServiceProvider.overrideWithValue(service),
            localRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(service.dispose);
        final notifier = container.read(deviceStateProvider.notifier);
        device.connectResult = const Failure(
          AppError(code: ErrorCode.bleError, message: 'connect failed'),
        );
        await notifier.connect(deviceId: 'bad');
        expect(
          container.read(deviceStateProvider).errorMessage,
          'connect failed',
        );
        notifier.clearError();
        expect(container.read(deviceStateProvider).errorMessage, isNull);

        device.readResult = const Failure(
          AppError(code: ErrorCode.modbusTimeout, message: 'read failed'),
        );
        await notifier.refresh();
        expect(container.read(deviceStateProvider).errorMessage, 'read failed');
        device.groupResult = const Failure(
          AppError(code: ErrorCode.modbusException, message: 'group failed'),
        );
        expect(await notifier.readGroup(0), isNull);
        expect(container.read(deviceStateProvider).busy, isFalse);

        device.failOperations('write failed');
        await notifier.writeGroup(const DataGroup(index: 0, name: 'M0'));
        expect(
          container.read(deviceStateProvider).errorMessage,
          'write failed',
        );
        await notifier.setVoltage(20);
        expect(container.read(deviceStateProvider).busy, isFalse);
        await notifier.disconnect();
      },
    );
  });

  testWidgets('metric and status cards render optional branches', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Column(
            children: [
              MetricCard(
                label: 'Voltage',
                value: '12.00',
                unit: 'V',
                icon: Icons.bolt,
                helper: 'stable',
              ),
              StatusBadge(label: 'Ready', color: AppColors.green),
            ],
          ),
        ),
      ),
    );
    expect(find.text('stable'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsOneWidget);
  });
}
