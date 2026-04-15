// Tag: Feature: pictogram-game-play, Property 1: Answer comparison is case-insensitive and whitespace-tolerant
@Tags(['pictogram-game-play-property-1'])
library;

// Feature: pictogram-game-play, Property 1

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/pictogram_play/presentation/bloc/pictogram_play_bloc.dart';

/// Generator for whitespace padding (spaces, tabs, newlines).
Generator<String> get _whitespacePadding =>
    any.intInRange(0, 10).map((length) {
      const chars = [' ', '\t', '  ', '   '];
      if (length == 0) return '';
      return List.generate(length, (i) => chars[i % chars.length]).join();
    });

/// Generator for non-empty answer strings (letters and digits).
Generator<String> get _answerString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'answer' : s);

/// Generator for case-toggled version of a string.
/// Randomly toggles each character to upper or lower case.
String _toggleCase(String input, int seed) {
  final chars = input.split('');
  for (var i = 0; i < chars.length; i++) {
    if ((seed + i) % 2 == 0) {
      chars[i] = chars[i].toUpperCase();
    } else {
      chars[i] = chars[i].toLowerCase();
    }
  }
  return chars.join();
}

void main() {
  // **Validates: Requirements 3.4, 6.4, 6.5**
  group(
    'Property 1: Answer comparison is case-insensitive and whitespace-tolerant',
    () {
      Glados3(
        _answerString,
        _whitespacePadding,
        _whitespacePadding,
        ExploreConfig(numRuns: 100),
      ).test(
        'checkAnswer returns true for same answer with arbitrary case and whitespace padding',
        (original, leadingPad, trailingPad) {
          // Create a padded + case-toggled version of the original
          final caseToggled = _toggleCase(original, original.length);
          final padded = '$leadingPad$caseToggled$trailingPad';

          expect(
            PictogramPlayBloc.checkAnswer(padded, original),
            isTrue,
            reason:
                'checkAnswer("$padded", "$original") should return true '
                '(padded trims to "${padded.trim()}", '
                'lowered: "${padded.trim().toLowerCase()}" vs "${original.trim().toLowerCase()}")',
          );
        },
      );

      Glados2(
        _answerString,
        _answerString,
        ExploreConfig(numRuns: 100),
      ).test(
        'checkAnswer returns false for two strings that differ after trim+lowercase',
        (a, b) {
          // Ensure the two strings actually differ after normalization
          final normalizedA = a.trim().toLowerCase();
          final normalizedB = b.trim().toLowerCase();

          // Skip if they happen to be equal after normalization
          if (normalizedA == normalizedB) return;

          expect(
            PictogramPlayBloc.checkAnswer(a, b),
            isFalse,
            reason:
                'checkAnswer("$a", "$b") should return false '
                '(normalized: "$normalizedA" vs "$normalizedB")',
          );
        },
      );
    },
  );
}
