// Cross-size and text-scale layout sweep for the SK120 UI.
//
// This is intentionally a Flutter-test (rather than a hardware/integration
// test) so it is deterministic and can run in CI without a BLE peripheral.
// The fixture uses the same deterministic service boundary as MockPowerDevice;
// no BLE, wall-clock, or random data is used by the test itself.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/app/theme/app_theme.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/data/repositories/in_memory_repository.dart';
import 'package:xy_sk120_control/features/communication_log/communication_log_page.dart';
import 'package:xy_sk120_control/features/control/control_page.dart';
import 'package:xy_sk120_control/features/groups/data_groups_page.dart';
import 'package:xy_sk120_control/features/monitoring/monitoring_page.dart';
import 'package:xy_sk120_control/features/settings/settings_page.dart';
import 'package:xy_sk120_control/features/settings/settings_subpages.dart';

import '../support/ui_fixture.dart';

const _baseline = _Profile('iphone_393x852', Size(393, 852), 1);

const _profiles = <_Profile>[
  _baseline,
  _Profile('iphone_375x812', Size(375, 812), 1),
  _Profile('iphone_430x932', Size(430, 932), 1),
  _Profile('android_360x800', Size(360, 800), 1),
  _Profile('android_393x873', Size(393, 873), 1),
  _Profile('android_412x915', Size(412, 915), 1),
  _Profile('tablet_768x1024', Size(768, 1024), 1),
  _Profile('tablet_800x1280', Size(800, 1280), 1),
  _Profile('tablet_landscape_1280x800', Size(1280, 800), 1),
  _Profile('desktop_1280x720', Size(1280, 720), 1),
  _Profile('desktop_1366x768', Size(1366, 768), 1),
  _Profile('desktop_1440x900', Size(1440, 900), 1),
  _Profile('desktop_1920x1080', Size(1920, 1080), 1),
];

const _textScales = <double>[1, 1.15, 1.3, 1.5, 2];

final _pages = <_PageCase>[
  _PageCase('control', () => const ControlPage()),
  _PageCase('monitor', () => const MonitoringPage()),
  _PageCase('data_groups', () => const DataGroupsPage()),
  _PageCase('settings', () => const SettingsPage()),
  _PageCase('protection', () => const ProtectionPage()),
  _PageCase('advanced', () => const AdvancedPowerPage()),
  _PageCase('device_settings', () => const DeviceSettingsPage()),
  _PageCase('communication_log', () => const CommunicationLogPage()),
];

void main() {
  // Every page is checked at every device profile at the default scale.
  for (final page in _pages) {
    for (final profile in _profiles) {
      testWidgets('${page.name} · ${profile.name} · textScale=1.0', (
        tester,
      ) async {
        await _pumpRegressionPage(tester, page.builder(), profile, 1);
        await _assertNoFlutterLayoutException(tester);
      });
    }
  }

  // The compact iPhone reference profile receives the complete text-scale
  // matrix, including the accessibility sizes most likely to expose a wrap.
  for (final page in _pages) {
    for (final scale in _textScales.skip(1)) {
      testWidgets('${page.name} · ${_baseline.name} · textScale=$scale', (
        tester,
      ) async {
        await _pumpRegressionPage(tester, page.builder(), _baseline, scale);
        await _assertNoFlutterLayoutException(tester);
      });
    }
  }
}

Future<void> _pumpRegressionPage(
  WidgetTester tester,
  Widget page,
  _Profile profile,
  double textScale,
) async {
  tester.view.physicalSize = profile.size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final device = UiMockPowerDevice()..seedConnectedOutput();
  final service = UiMockPowerDeviceService(device);
  addTearDown(service.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        powerDeviceServiceProvider.overrideWithValue(service),
        localRepositoryProvider.overrideWithValue(InMemoryRepository()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: const ValueKey('ui-regression-root'),
          child: page,
        ),
      ),
    ),
  );
  // Some dashboard surfaces intentionally keep a progress/ambient animation
  // alive. A bounded frame is deterministic here and avoids waiting forever
  // on an animation that is part of the UI itself.
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _assertNoFlutterLayoutException(WidgetTester tester) async {
  // takeException surfaces RenderFlex/RenderBox errors that Flutter normally
  // paints into the test tree. They are hard failures rather than warnings.
  final exception = tester.takeException();
  expect(exception, isNull, reason: 'LAYOUT_OVERFLOW or widget exception');
}

class _Profile {
  const _Profile(this.name, this.size, this.textScale);

  final String name;
  final Size size;
  final double textScale;
}

class _PageCase {
  const _PageCase(this.name, this.builder);

  final String name;
  final Widget Function() builder;
}
