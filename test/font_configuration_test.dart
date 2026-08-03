import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:xy_sk120_control/app/theme/app_theme.dart';

void main() {
  test('bundles AppSans and its SIL OFL license', () {
    const fontPath = 'assets/fonts/NotoSansCJKsc-VF.otf';
    const licensePath = 'assets/fonts/OFL.txt';
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(buildAppTheme().textTheme.bodyMedium?.fontFamily, AppFonts.sans);
    expect(File(fontPath).lengthSync(), greaterThan(25 * 1024 * 1024));
    expect(
      File(licensePath).readAsStringSync(),
      contains('SIL OPEN FONT LICENSE Version 1.1'),
    );
    expect(pubspec, contains('family: ${AppFonts.sans}'));
    expect(pubspec, contains('asset: $fontPath'));
    expect(pubspec, contains('- $licensePath'));
  });
}
