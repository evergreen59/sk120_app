import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/app/app.dart';

void main() {
  testWidgets('setpoint controls select voltage and current adjustment steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: XYSk120App()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('启用演示模式'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('12.00 V'), findsOneWidget);
    expect(find.text('1.250 A'), findsOneWidget);

    final voltageSteps = tester.widget<SegmentedButton<double>>(
      find.byKey(const ValueKey('adjust-step-V')),
    );
    voltageSteps.onSelectionChanged?.call(<double>{0.01});
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('adjust-increase-V')));
    await tester.pump();
    expect(find.text('12.01 V'), findsOneWidget);

    final currentSteps = tester.widget<SegmentedButton<double>>(
      find.byKey(const ValueKey('adjust-step-A')),
    );
    currentSteps.onSelectionChanged?.call(<double>{0.001});
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('adjust-increase-A')));
    await tester.pump();
    expect(find.text('1.251 A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
