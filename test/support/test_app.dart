import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/app/theme/app_theme.dart';
import 'package:xy_sk120_control/application/providers.dart';
import 'package:xy_sk120_control/data/repositories/in_memory_repository.dart';
import 'package:xy_sk120_control/domain/repositories/local_repository.dart';
import 'package:xy_sk120_control/domain/services/power_device.dart';

Future<void> pumpTestPage(
  WidgetTester tester, {
  required Widget child,
  required PowerDeviceService service,
  LocalRepository? repository,
  Size size = const Size(1200, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        powerDeviceServiceProvider.overrideWithValue(service),
        localRepositoryProvider.overrideWithValue(
          repository ?? InMemoryRepository(),
        ),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: child),
    ),
  );
}
