import '../value_objects/dictation_result.dart';
import '../value_objects/word_comparison.dart';

/// Splits [text] by whitespace and returns the number of non-empty tokens.
int countWords(String text) =>
    text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

/// Compares [userContent] against [originalContent] word-by-word
/// (case-insensitive, positional matching).
///
/// Returns a record of `(List<WordComparison>, DictationResult)`:
/// - The list length equals the number of words in [originalContent].
/// - Extra words in [userContent] are ignored.
/// - Missing words in [userContent] produce `WordComparison(userWord: null, isCorrect: false)`.
/// - Empty [originalContent] yields `DictationResult(correctWords: 0, totalWords: 0)`.
(List<WordComparison>, DictationResult) compareWords(
  String originalContent,
  String userContent,
) {
  final originalWords =
      originalContent.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final userWords =
      userContent.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  final totalWords = originalWords.length;

  if (totalWords == 0) {
    return (
      <WordComparison>[],
      const DictationResult(correctWords: 0, totalWords: 0),
    );
  }

  var correctWords = 0;
  final comparisons = <WordComparison>[];

  for (var i = 0; i < totalWords; i++) {
    final original = originalWords[i];
    final user = i < userWords.length ? userWords[i] : null;
    final isCorrect =
        user != null && original.toLowerCase() == user.toLowerCase();

    if (isCorrect) correctWords++;

    comparisons.add(
      WordComparison(
        originalWord: original,
        userWord: user,
        isCorrect: isCorrect,
      ),
    );
  }

  return (
    comparisons,
    DictationResult(correctWords: correctWords, totalWords: totalWords),
  );
}
