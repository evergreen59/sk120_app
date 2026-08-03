import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/app/theme/app_theme.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/core/result/result.dart';
import 'package:xy_sk120_control/data/repositories/in_memory_repository.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';
import 'package:xy_sk120_control/features/groups/data_groups_page.dart';
import 'package:xy_sk120_control/features/settings/settings_page.dart';

void main() {
  testWidgets(
    'settings expose decoded protocol controls and protection state',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final device = _TrackingPowerDevice();
      final service = PowerDeviceService(device);
      addTearDown(service.dispose);

      await tester.pumpWidget(
        _testApp(service: service, child: const SettingsPage()),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('正常 (NORMAL)'), findsOneWidget);
      final lock = tester.widget<Switch>(
        find.byKey(const ValueKey('key-lock-switch')),
      );
      expect(lock.value, isFalse);
      lock.onChanged?.call(true);
      await tester.pump();
      expect(device.status.keyLocked, isTrue);

      final backlight = tester.widget<Slider>(
        find.byKey(const ValueKey('backlight-slider')),
      );
      expect(backlight.min, 0);
      expect(backlight.max, 5);
      expect(backlight.divisions, 5);
      backlight.onChanged?.call(5);
      await tester.pump();
      expect(device.status.backlightLevel, 5);

      final baud = tester.widget<DropdownButton<DeviceBaudRate>>(
        find.byKey(const ValueKey('baud-rate-menu')),
      );
      expect(baud.items, hasLength(9));
      expect(baud.value, DeviceBaudRate.baud115200);
      baud.onChanged?.call(DeviceBaudRate.baud57600);
      await tester.pump();
      expect(device.status.baudRate, DeviceBaudRate.baud57600);
      expect(device.status.baudRateRaw, 5);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('group preview confirms activation instead of rewriting a slot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final device = _TrackingPowerDevice();
    final service = PowerDeviceService(device);
    addTearDown(service.dispose);

    await tester.pumpWidget(
      _testApp(service: service, child: const DataGroupsPage()),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('预览并加载').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('预览 M0'), findsOneWidget);
    expect(find.textContaining('EXTRACT-M'), findsOneWidget);

    await tester.tap(find.text('确认加载'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(device.activatedGroups, [0]);
    expect(device.groupWriteCount, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _testApp({required PowerDeviceService service, required Widget child}) =>
    ProviderScope(
      overrides: [
        powerDeviceServiceProvider.overrideWithValue(service),
        localRepositoryProvider.overrideWithValue(InMemoryRepository()),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: child),
    );

class _TrackingPowerDevice extends PowerDeviceBase {
  _TrackingPowerDevice()
    : super(
        id: 'widget-device',
        name: 'Widget Device',
        mode: DeviceMode.real,
        initialStatus: const DeviceStatus(
          connectionState: DeviceConnectionState.connected,
          outputState: OutputState.off,
          cvccState: CvccState.cv,
          protectionStatus: ProtectionStatus.normal,
          protectionRaw: 0,
          keyLocked: false,
          backlightLevel: 3,
          voltageSet: 12,
          currentSet: 1.25,
          baudRate: DeviceBaudRate.baud115200,
          baudRateRaw: 6,
        ),
      );

  final List<int> activatedGroups = [];
  int groupWriteCount = 0;
  DataGroup group = const DataGroup(
    index: 0,
    name: 'M0',
    voltageSet: 12,
    currentSet: 1.25,
    overPowerProtection: 20,
  );

  @override
  Future<Result<void>> connect({String? deviceId}) async => const Success(null);

  @override
  Future<Result<void>> disconnect() async => const Success(null);

  @override
  Future<Result<DeviceStatus>> readStatus() async => Success(status);

  @override
  Future<Result<void>> setVoltage(double volts) async => const Success(null);

  @override
  Future<Result<void>> setCurrent(double amps) async => const Success(null);

  @override
  Future<Result<void>> setOutput(bool enabled) async => const Success(null);

  @override
  Future<Result<DataGroup>> readDataGroup(int index) async =>
      Success(group.copyWith(name: 'M$index'));

  @override
  Future<Result<void>> activateDataGroup(int index) async {
    activatedGroups.add(index);
    return const Success(null);
  }

  @override
  Future<Result<void>> writeDataGroup(DataGroup group) async {
    groupWriteCount++;
    this.group = group;
    return const Success(null);
  }

  @override
  Future<Result<void>> setKeyLock(bool locked) async {
    emitStatus(status.copyWith(keyLocked: locked));
    return const Success(null);
  }

  @override
  Future<Result<void>> setBacklight(int level) async {
    emitStatus(status.copyWith(backlightLevel: level));
    return const Success(null);
  }

  @override
  Future<Result<void>> setBaudRate(DeviceBaudRate baudRate) async {
    emitStatus(status.copyWith(baudRate: baudRate, baudRateRaw: baudRate.code));
    return const Success(null);
  }
}
