import 'dart:io';

class CoverageSummary {
  const CoverageSummary({
    required this.linesHit,
    required this.linesFound,
    required this.branchesHit,
    required this.branchesFound,
  });

  final int linesHit;
  final int linesFound;
  final int branchesHit;
  final int branchesFound;

  double get linePercent => linesFound == 0 ? 100 : linesHit * 100 / linesFound;
  double get branchPercent =>
      branchesFound == 0 ? 100 : branchesHit * 100 / branchesFound;
}

CoverageSummary parseLcov(String content, {String excludeSuffix = '.g.dart'}) {
  var excluded = false;
  var linesHit = 0;
  var linesFound = 0;
  var branchesHit = 0;
  var branchesFound = 0;
  for (final line in content.split('\n')) {
    if (line.startsWith('SF:')) {
      excluded = line.substring(3).endsWith(excludeSuffix);
    } else if (line == 'end_of_record') {
      excluded = false;
    } else if (!excluded && line.startsWith('DA:')) {
      final fields = line.substring(3).split(',');
      if (fields.length >= 2) {
        linesFound++;
        if ((int.tryParse(fields[1]) ?? 0) > 0) linesHit++;
      }
    } else if (!excluded && line.startsWith('BRDA:')) {
      final fields = line.substring(5).split(',');
      if (fields.length >= 4) {
        branchesFound++;
        if (fields[3] != '-' && (int.tryParse(fields[3]) ?? 0) > 0) {
          branchesHit++;
        }
      }
    }
  }
  return CoverageSummary(
    linesHit: linesHit,
    linesFound: linesFound,
    branchesHit: branchesHit,
    branchesFound: branchesFound,
  );
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/check_coverage.dart <lcov.info> '
      '--min-line 70 --min-branch 60 --exclude-suffix .g.dart',
    );
    exitCode = 64;
    return;
  }
  final input = arguments.first;
  double minLine = 70;
  double minBranch = 60;
  var excludeSuffix = '.g.dart';
  for (var index = 1; index < arguments.length; index++) {
    switch (arguments[index]) {
      case '--min-line':
        minLine = double.parse(arguments[++index]);
      case '--min-branch':
        minBranch = double.parse(arguments[++index]);
      case '--exclude-suffix':
        excludeSuffix = arguments[++index];
      default:
        stderr.writeln('Unknown argument: ${arguments[index]}');
        exitCode = 64;
        return;
    }
  }
  final file = File(input);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $input');
    exitCode = 66;
    return;
  }
  final summary = parseLcov(
    file.readAsStringSync(),
    excludeSuffix: excludeSuffix,
  );
  stdout.writeln(
    'Line coverage: ${summary.linesHit}/${summary.linesFound} '
    '(${summary.linePercent.toStringAsFixed(2)}%)',
  );
  stdout.writeln(
    'Branch coverage: ${summary.branchesHit}/${summary.branchesFound} '
    '(${summary.branchPercent.toStringAsFixed(2)}%)',
  );
  if (summary.linePercent < minLine || summary.branchPercent < minBranch) {
    stderr.writeln(
      'Coverage gate failed: required line >= $minLine% and '
      'branch >= $minBranch%.',
    );
    exitCode = 1;
  }
}
