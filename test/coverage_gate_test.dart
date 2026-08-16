import 'package:flutter_test/flutter_test.dart';

import '../tool/check_coverage.dart';

void main() {
  test('parses line and branch coverage while excluding generated sources', () {
    const lcov = '''
SF:lib/a.dart
DA:1,1
DA:2,0
BRDA:1,0,0,2
BRDA:1,0,1,-
end_of_record
SF:lib/a.g.dart
DA:1,0
BRDA:1,0,0,-
end_of_record
''';

    final summary = parseLcov(lcov);

    expect(summary.linesHit, 1);
    expect(summary.linesFound, 2);
    expect(summary.linePercent, 50);
    expect(summary.branchesHit, 1);
    expect(summary.branchesFound, 2);
    expect(summary.branchPercent, 50);
  });

  test('empty categories are treated as fully covered', () {
    final summary = parseLcov('SF:lib/a.dart\nend_of_record\n');
    expect(summary.linePercent, 100);
    expect(summary.branchPercent, 100);
  });
}
