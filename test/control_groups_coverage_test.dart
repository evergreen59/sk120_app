import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/domain/models/device_models.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';
import 'package:xy_sk120_control/features/control/control_page.dart';
import 'package:xy_sk120_control/features/groups/data_groups_page.dart';
import 'package:xy_sk120_control/shared/widgets/glass_card.dart';

import 'support/test_app.dart';
import 'support/test_power_device.dart';

void main() {
  testWidgets('control confirms output and applies a quick preset', (
    tester,
  ) async {
    final device = TestPowerDevice(
      status: const DeviceStatus(
        connectionState: DeviceConnectionState.connected,
        outputState: OutputState.off,
        cvccState: CvccState.cv,
        protectionStatus: ProtectionStatus.normal,
        voltageSet: 12,
        currentSet: 1.25,
        outputVoltage: 11.9,
        outputCurrent: 1.2,
        outputPower: 14.28,
        inputVoltage: 24,
        internalTemperature: 32,
      ),
    );
    final service = PowerDeviceService(device);
    addTearDown(service.dispose);
    await pumpTestPage(
      tester,
      child: const ControlPage(),
      service: service,
      size: const Size(1200, 1200),
    );
    await tester.pump();
    expect(find.text('Output OFF'), findsOneWidget);

    final toggle = tester.widget<ToggleSwitch>(find.byType(ToggleSwitch));
    toggle.onChanged?.call(true);
    await tester.pumpAndSettle();
    expect(find.text('确认开启输出'), findsOneWidget);
    expect(find.text('电压：12.000 V'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(device.outputs, isEmpty);

    tester
        .widget<ToggleSwitch>(find.byType(ToggleSwitch))
        .onChanged
        ?.call(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认开启'));
    await tester.pump();
    await tester.pump();
    expect(device.outputs, [true]);

    await tester.scrollUntilVisible(
      find.text('5 V / 1 A'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('5 V / 1 A'));
    await tester.pump();
    await tester.pump();
    expect(device.voltages, contains(5));
    expect(device.currents, contains(1));
  });

  testWidgets('data groups edit values and show output safety note', (
    tester,
  ) async {
    final device = TestPowerDevice(
      status: const DeviceStatus(
        connectionState: DeviceConnectionState.connected,
        outputState: OutputState.on,
      ),
    );
    final service = PowerDeviceService(device);
    addTearDown(service.dispose);
    await pumpTestPage(
      tester,
      child: const DataGroupsPage(),
      service: service,
      size: const Size(1200, 1200),
    );
    await tester.pump();
    expect(find.textContaining('输出开启时不能保存或调用数据组'), findsOneWidget);

    await tester.tap(find.byTooltip('编辑数据组').first);
    await tester.pumpAndSettle();
    expect(find.text('编辑 M0'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Bench');
    await tester.enterText(fields.at(1), '24');
    await tester.enterText(fields.at(2), '2.5');
    await tester.enterText(fields.at(3), '60');
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump();
    expect(device.writtenGroups, hasLength(1));
    expect(device.writtenGroups.single.name, 'Bench');
    expect(device.writtenGroups.single.voltageSet, 24);

    await tester.tap(find.byTooltip('读取数据组').first);
    await tester.pump();
    await tester.pump();
    expect(device.calls, contains('readGroup:0'));
  });
}
