import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/shared/widgets/glass_card.dart';

void main() {
  testWidgets('glass toggle animates between shadow states safely', (
    tester,
  ) async {
    var value = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: ToggleSwitch(
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pump(const Duration(milliseconds: 110));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(value, isFalse);
  });
}
