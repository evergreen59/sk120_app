import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:xy_sk120_control/app/app.dart';
import 'package:xy_sk120_control/shared/widgets/glass_card.dart';

void main() {
  patrolTest('mock-device critical navigation and output flow', ($) async {
    await $.pumpWidgetAndSettle(const ProviderScope(child: XYSk120App()));

    expect($('发现设备'), findsOneWidget);
    await $('启用演示模式').tap();
    await $.pump(const Duration(seconds: 1));

    expect($('Connected'), findsOneWidget);
    expect($('Output OFF'), findsOneWidget);

    await $(ToggleSwitch).scrollTo().tap();
    await $.pumpAndSettle();
    expect($('确认开启输出'), findsOneWidget);
    await $('确认开启').tap();
    await $.pump(const Duration(milliseconds: 500));
    expect($('Output ON'), findsOneWidget);

    await $(Icons.monitor_heart_outlined).tap();
    await $.pump(const Duration(milliseconds: 300));
    expect($('Real-time Monitor'), findsOneWidget);

    await $(Icons.grid_view_rounded).tap();
    await $.pump(const Duration(milliseconds: 300));
    expect($('Data Groups'), findsOneWidget);

    await $(Icons.settings_outlined).tap();
    await $.pump(const Duration(milliseconds: 300));
    expect($('Settings'), findsOneWidget);
    expect($('Device Settings'), findsOneWidget);
  });
}
