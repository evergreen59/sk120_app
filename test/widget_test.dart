import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xy_sk120_control/app/app.dart';

void main() {
  testWidgets('starts in the real-device scan view', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: XYSk120App()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('控制台'), findsOneWidget);
    expect(find.text('发现设备'), findsOneWidget);
    expect(find.text('开始扫描'), findsOneWidget);
  });
}
