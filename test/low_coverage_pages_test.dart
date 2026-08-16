import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/app/theme/app_theme.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/data/repositories/in_memory_repository.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';
import 'package:xy_sk120_control/features/communication_log/communication_log_page.dart';
import 'package:xy_sk120_control/features/history/history_page.dart';
import 'package:xy_sk120_control/features/monitoring/monitoring_page.dart';
import 'package:xy_sk120_control/features/settings/settings_subpages.dart';
import 'package:xy_sk120_control/shared/widgets/glass_card.dart';

import 'support/test_app.dart';
import 'support/test_power_device.dart';

void main() {
  group('communication log page', () {
    testWidgets('loads, filters, searches and exports logs', (tester) async {
      final repository = InMemoryRepository();
      await repository.saveCommunicationLog(
        CommunicationLogEntry(
          deviceId: 'test-device',
          timestamp: DateTime(2026, 1, 1, 12),
          direction: CommunicationDirection.tx,
          rawBytes: const [1, 3, 0, 0],
          parsedMessage: 'read registers',
          success: true,
        ),
      );
      await repository.saveCommunicationLog(
        CommunicationLogEntry(
          deviceId: 'test-device',
          timestamp: DateTime(2026, 1, 1, 12, 0, 1),
          direction: CommunicationDirection.rx,
          rawBytes: const [1, 0x83, 2],
          parsedMessage: 'exception response',
          success: false,
          error: 'illegal address',
        ),
      );
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);

      await pumpTestPage(
        tester,
        child: const CommunicationLogPage(),
        service: service,
        repository: repository,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.text('TX'), findsWidgets);
      expect(find.text('RX'), findsWidgets);
      expect(find.text('01 83 02'), findsOneWidget);
      expect(find.text('illegal address'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'RX'));
      await tester.pump();
      expect(find.text('01 83 02'), findsNothing);
      await tester.enterText(find.byType(TextField), 'read');
      await tester.pump();
      expect(find.text('read registers'), findsOneWidget);

      await tester.tap(find.byTooltip('暂停'));
      await tester.pump();
      expect(find.byTooltip('继续'), findsOneWidget);

      await tester.tap(find.byTooltip('导出 CSV'));
      await tester.pumpAndSettle();
      expect(find.text('CSV 导出内容'), findsOneWidget);
      expect(find.textContaining('device_id,timestamp'), findsOneWidget);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('导出 JSON'));
      await tester.pumpAndSettle();
      expect(find.text('JSON 导出内容'), findsOneWidget);
      expect(find.textContaining('exception response'), findsOneWidget);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no records match', (tester) async {
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);
      await pumpTestPage(
        tester,
        child: const CommunicationLogPage(),
        service: service,
      );
      await tester.pump();
      expect(find.text('暂无符合条件的通信记录'), findsOneWidget);
    });
  });

  group('history page', () {
    testWidgets('shows session details, refresh and both exports', (
      tester,
    ) async {
      final repository = InMemoryRepository();
      await repository.saveSession(
        OutputSession(
          deviceId: 'test-device',
          startTime: DateTime(2026, 1, 2, 3, 4, 5),
          endTime: DateTime(2026, 1, 2, 3, 6, 5),
          outputDuration: const Duration(minutes: 2),
          averageVoltage: 12.5,
          averageCurrent: 1.25,
          maxPower: 15.625,
          totalAh: 10,
          totalWh: 20,
        ),
      );
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);
      await pumpTestPage(
        tester,
        child: const HistoryPage(),
        service: service,
        repository: repository,
      );
      await tester.pump();
      expect(find.text('2026-01-02 03:04'), findsOneWidget);

      await tester.tap(find.text('2026-01-02 03:04'));
      await tester.pumpAndSettle();
      expect(find.text('会话详情'), findsOneWidget);
      expect(find.textContaining('平均电压：12.500 V'), findsOneWidget);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('刷新'));
      await tester.pump();
      await tester.pump();
      expect(find.text('2026-01-02 03:04'), findsOneWidget);

      for (final tooltip in ['导出 CSV', '导出 JSON']) {
        await tester.tap(find.byTooltip(tooltip));
        await tester.pumpAndSettle();
        expect(find.textContaining('导出内容'), findsOneWidget);
        await tester.tap(find.text('关闭'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('shows empty and error states', (tester) async {
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);
      await pumpTestPage(tester, child: const HistoryPage(), service: service);
      await tester.pump();
      expect(find.text('暂无输出历史'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpTestPage(
        tester,
        child: const HistoryPage(),
        service: service,
        repository: _FailingRepository(),
      );
      await tester.pump();
      expect(find.text('历史读取失败'), findsOneWidget);
      expect(find.textContaining('database offline'), findsOneWidget);
    });
  });

  testWidgets('monitoring renders metrics, chart, pause and clear states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final state = DeviceUiState(
      mode: DeviceMode.real,
      status: const DeviceStatus(
        connectionState: DeviceConnectionState.connected,
        outputState: OutputState.on,
        cvccState: CvccState.cc,
        protectionStatus: ProtectionStatus.normal,
        outputVoltage: 12.345,
        outputCurrent: 1.234,
        outputPower: 15.23,
        inputVoltage: 24.1,
        internalTemperature: 36.5,
        outputAh: 12,
        outputWh: 34,
        outputDuration: Duration(hours: 1, minutes: 2, seconds: 3),
      ),
      samples: [
        MeasurementSample(
          deviceId: 'test',
          timestamp: now.subtract(const Duration(seconds: 2)),
          voltage: 12,
          current: 1,
          power: 12,
        ),
        MeasurementSample(
          deviceId: 'test',
          timestamp: now,
          voltage: 13,
          current: 1.1,
          power: 14.3,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceStateProvider.overrideWithBuild((ref, notifier) => state),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const MonitoringPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('12.345'), findsOneWidget);
    expect(find.text('1.234'), findsOneWidget);
    expect(find.text('CC'), findsOneWidget);
    expect(find.textContaining('1 h 02 min 03 s'), findsOneWidget);
    expect(find.text('等待采样数据…'), findsNothing);

    await tester.tap(find.byTooltip('暂停'));
    await tester.pump();
    expect(find.byTooltip('继续'), findsOneWidget);
    await tester.tap(find.byTooltip('清空曲线'));
    await tester.pump();
    expect(find.text('等待采样数据…'), findsOneWidget);
  });

  group('settings subpages', () {
    testWidgets('protection and advanced controls update and save', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ProtectionPage()),
      );
      final switches = find.byType(ToggleSwitch);
      expect(switches, findsNWidgets(9));
      await tester.tap(switches.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      expect(find.text('Protection settings saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const AdvancedPowerPage()),
      );
      await tester.tap(find.byType(ToggleSwitch));
      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(80);
      await tester.pump();
      expect(find.text('80.0 W'), findsOneWidget);
      await tester.tap(find.text('Always ON'));
      await tester.pump();
      await tester.tap(find.text('Save Settings'));
      await tester.pump();
      expect(find.text('Advanced settings saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('device settings invoke connected device controls', (
      tester,
    ) async {
      final device = TestPowerDevice(
        status: const DeviceStatus(
          connectionState: DeviceConnectionState.connected,
          outputState: OutputState.off,
          backlightLevel: 3,
          baudRate: DeviceBaudRate.baud115200,
        ),
      );
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);
      await pumpTestPage(
        tester,
        child: const DeviceSettingsPage(),
        service: service,
        size: const Size(1000, 1100),
      );
      await tester.pump();
      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged?.call(5);
      await tester.pump();
      await tester.tap(find.byType(ToggleSwitch));
      await tester.pump();
      expect(device.calls, contains('setBacklight:5'));
      expect(device.calls, contains('setBuzzer:true'));
    });

    testWidgets('BLE page scans, lists, stops and connects', (tester) async {
      final device = TestPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);
      await pumpTestPage(
        tester,
        child: const BleDevicesPage(),
        service: service,
      );
      await tester.pump();
      expect(find.text('No nearby devices'), findsOneWidget);
      await tester.tap(find.text('Scan'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Looking for XY-SK120…'), findsOneWidget);
      device.scanController.add(
        const BleDeviceInfo(id: 'ble-1', name: 'SK120', rssi: -42),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('SK120'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Stop Scan'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

class _FailingRepository extends InMemoryRepository {
  @override
  Future<List<OutputSession>> loadSessions(String deviceId) =>
      Future<List<OutputSession>>.error(StateError('database offline'));
}
