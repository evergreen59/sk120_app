import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/features/communication_log/communication_log_page.dart';
import 'package:xy_sk120_control/features/control/control_page.dart';
import 'package:xy_sk120_control/features/groups/data_groups_page.dart';
import 'package:xy_sk120_control/features/monitoring/monitoring_page.dart';
import 'package:xy_sk120_control/features/settings/settings_page.dart';
import 'package:xy_sk120_control/features/settings/settings_subpages.dart';

import '../support/test_app.dart';
import '../support/ui_fixture.dart';

const _referenceSize = Size(393, 852);
const _rootKey = ValueKey('golden-root');

final _pages = <_GoldenPage>[
  _GoldenPage('control_default', () => const ControlPage()),
  _GoldenPage('monitor_default', () => const MonitoringPage()),
  _GoldenPage('data_groups_default', () => const DataGroupsPage()),
  _GoldenPage('settings_default', () => const SettingsPage()),
  _GoldenPage('protection_normal', () => const ProtectionPage()),
  _GoldenPage('advanced_default', () => const AdvancedPowerPage()),
  _GoldenPage('device_settings_default', () => const DeviceSettingsPage()),
  _GoldenPage('communication_log_default', () => const CommunicationLogPage()),
];

void main() {
  for (final page in _pages) {
    testWidgets('${page.name} visual baseline', (tester) async {
      final device = UiMockPowerDevice()..seedConnectedOutput();
      final service = UiMockPowerDeviceService(device);
      addTearDown(service.dispose);

      await pumpTestPage(
        tester,
        child: RepaintBoundary(key: _rootKey, child: page.builder()),
        service: service,
        size: _referenceSize,
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(_rootKey),
        matchesGoldenFile(
          '../../test_goldens/macos/iphone_393x852/${page.name}.png',
        ),
      );
    });
  }
}

class _GoldenPage {
  const _GoldenPage(this.name, this.builder);

  final String name;
  final Widget Function() builder;
}
