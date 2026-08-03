import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xy_sk120_control/shared/widgets/number_input_dialog.dart';

void main() {
  testWidgets('number input dialog closes safely on cancel and confirm', (
    tester,
  ) async {
    double? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showNumberInputDialog<double>(
                  context,
                  title: '设置电压设定',
                  initialValue: '12.000',
                  labelText: '0–36',
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  parse: (text) {
                    final value = double.tryParse(text);
                    return value != null && value >= 0 && value <= 36
                        ? value
                        : null;
                  },
                );
              },
              child: const Text('编辑'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '24.5');
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();

    expect(result, 24.5);
    expect(tester.takeException(), isNull);
  });
}
