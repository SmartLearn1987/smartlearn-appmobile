// Tag: Feature: subjects, Property 3: Curriculum name validation rejects empty and whitespace-only input
@Tags(['subjects-property-3'])
library;

// Feature: subjects, Property 3: Curriculum name validation rejects empty and whitespace-only input

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/subjects/domain/validators/curriculum_validators.dart';

/// Generator for whitespace-only strings (including empty).
Generator<String> get _whitespaceOnly => any.intInRange(0, 10).map((length) {
      const whitespaceChars = [' ', '\t', '\n', '\r', '\u00A0'];
      if (length == 0) return '';
      return List.generate(
        length,
        (i) => whitespaceChars[i % whitespaceChars.length],
      ).join();
    });

/// Generator for strings containing at least one non-whitespace character.
Generator<String> get _withNonWhitespace =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

void main() {
  // **Validates: Requirements 11.4**
  group('Property 3: Curriculum name validation rejects empty and whitespace-only input', () {
    Glados(_whitespaceOnly).test(
      'whitespace-only strings are rejected',
      (input) {
        final result = validateCurriculumName(input);
        expect(
          result,
          isNotNull,
          reason:
              'Expected validation to reject whitespace-only input "${input.replaceAll('\n', '\\n').replaceAll('\t', '\\t')}" (length ${input.length})',
        );
      },
    );

    Glados(_withNonWhitespace).test(
      'strings with non-whitespace characters are accepted',
      (input) {
        final result = validateCurriculumName(input);
        expect(
          result,
          isNull,
          reason:
              'Expected validation to accept "$input" but got error: $result',
        );
      },
    );
  });
}
