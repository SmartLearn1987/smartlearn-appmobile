// Tag: Feature: quizlet-flashcard, Property 10: CSV parsing
@Tags(['quizlet-flashcard-property-10'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';

Generator<String> get _lineWithoutNewline =>
    any.letterOrDigits.map((s) => s.replaceAll('\n', '').replaceAll('\r', ''));

Generator<_CsvLineCase> get _csvLineCase => any.combine3(
      any.bool,
      _lineWithoutNewline,
      _lineWithoutNewline,
      (bool isValid, String left, String right) => _CsvLineCase(
        rawLine: isValid ? '$left,$right' : left,
        isValid: isValid,
      ),
    );

class _CsvLineCase {
  final String rawLine;
  final bool isValid;

  const _CsvLineCase({
    required this.rawLine,
    required this.isValid,
  });
}

void main() {
  group('Property 10: CSV parsing tách đúng term/definition', () {
    Glados(
      any.listWithLengthInRange(0, 40, _csvLineCase),
      ExploreConfig(numRuns: 100),
    ).test(
      'parseCsvToCards tách tại dấu phẩy đầu tiên, bỏ qua dòng không hợp lệ',
      (lineCases) {
        final lines = lineCases.map((lineCase) => lineCase.rawLine).toList();

        final csv = lines.join('\n');
        final parsed = parseCsvToCards(csv);

        final expected = <CardFormData>[];
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) {
            continue;
          }
          final commaIndex = trimmedLine.indexOf(',');
          if (commaIndex < 0) {
            continue;
          }
          expected.add(
            CardFormData(
              term: trimmedLine.substring(0, commaIndex).trim(),
              definition: trimmedLine.substring(commaIndex + 1).trim(),
            ),
          );
        }

        expect(parsed, equals(expected));
        expect(parsed.length, equals(expected.length));
      },
    );
  });
}
