import 'package:flutter/material.dart';

import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';

/// Normalize tiếng Việt về dạng ASCII không dấu để so sánh linh hoạt.
/// Ví dụ: "Đồng Nai" → "dong nai", "Sơn La" → "son la"
String _normalize(String s) {
  const map = {
    'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
    'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
    'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
    'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
    'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
    'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
    'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
    'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
    'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
    'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
    'đ': 'd',
    'À': 'a', 'Á': 'a', 'Ả': 'a', 'Ã': 'a', 'Ạ': 'a',
    'Ă': 'a', 'Ằ': 'a', 'Ắ': 'a', 'Ẳ': 'a', 'Ẵ': 'a', 'Ặ': 'a',
    'Â': 'a', 'Ầ': 'a', 'Ấ': 'a', 'Ẩ': 'a', 'Ẫ': 'a', 'Ậ': 'a',
    'È': 'e', 'É': 'e', 'Ẻ': 'e', 'Ẽ': 'e', 'Ẹ': 'e',
    'Ê': 'e', 'Ề': 'e', 'Ế': 'e', 'Ể': 'e', 'Ễ': 'e', 'Ệ': 'e',
    'Ì': 'i', 'Í': 'i', 'Ỉ': 'i', 'Ĩ': 'i', 'Ị': 'i',
    'Ò': 'o', 'Ó': 'o', 'Ỏ': 'o', 'Õ': 'o', 'Ọ': 'o',
    'Ô': 'o', 'Ồ': 'o', 'Ố': 'o', 'Ổ': 'o', 'Ỗ': 'o', 'Ộ': 'o',
    'Ơ': 'o', 'Ờ': 'o', 'Ớ': 'o', 'Ở': 'o', 'Ỡ': 'o', 'Ợ': 'o',
    'Ù': 'u', 'Ú': 'u', 'Ủ': 'u', 'Ũ': 'u', 'Ụ': 'u',
    'Ư': 'u', 'Ừ': 'u', 'Ứ': 'u', 'Ử': 'u', 'Ữ': 'u', 'Ự': 'u',
    'Ỳ': 'y', 'Ý': 'y', 'Ỷ': 'y', 'Ỹ': 'y', 'Ỵ': 'y',
    'Đ': 'd',
  };
  return s.split('').map((c) => map[c] ?? c.toLowerCase()).join();
}

bool _matchAnswer(String userInput, String correctAnswer) {
  final user = _normalize(userInput.trim().replaceAll(' ', ''));
  final correct = _normalize(correctAnswer.trim().replaceAll(' ', ''));
  return user == correct;
}

/// Mỗi câu hỏi giữ:
///   - [words]            : danh sách các từ trong đáp án (split theo khoảng trắng)
///   - [wordControllers]  : mỗi từ một [TextEditingController] — phù hợp với Pinput
///                          (Pinput cần 1 controller giữ toàn bộ chuỗi của ô PIN).
class GameSessionController {
  GameSessionController({required this.questions}) {
    _init();
  }

  final List<PictogramEntity> questions;

  late final List<List<String>> _words;
  late final List<List<TextEditingController>> _wordControllers;

  void _init() {
    _words = questions.map((q) {
      return q.answer
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
    }).toList();
    _wordControllers = _words.map((words) {
      return words.map((_) => TextEditingController()).toList();
    }).toList();
  }

  List<String> wordsFor(int questionIndex) => _words[questionIndex];

  List<TextEditingController> wordControllersFor(int questionIndex) =>
      _wordControllers[questionIndex];

  String currentAnswerFor(int questionIndex) =>
      _wordControllers[questionIndex].map((c) => c.text).join();

  bool isCompleteFor(int questionIndex) {
    final words = _words[questionIndex];
    final controllers = _wordControllers[questionIndex];
    for (var i = 0; i < words.length; i++) {
      if (controllers[i].text.length != words[i].length) return false;
    }
    return true;
  }

  void clearQuestion(int questionIndex) {
    for (final c in _wordControllers[questionIndex]) {
      c.clear();
    }
  }

  void reset() {
    for (var i = 0; i < questions.length; i++) {
      clearQuestion(i);
    }
  }

  Map<int, AnswerResult> buildResults() {
    final results = <int, AnswerResult>{};
    for (var i = 0; i < questions.length; i++) {
      final isCorrect = _matchAnswer(
        currentAnswerFor(i),
        questions[i].answer,
      );
      results[i] = isCorrect ? AnswerResult.correct : AnswerResult.incorrect;
    }
    return results;
  }

  int get correctCount {
    var count = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_matchAnswer(currentAnswerFor(i), questions[i].answer)) {
        count++;
      }
    }
    return count;
  }

  void dispose() {
    for (final list in _wordControllers) {
      for (final c in list) {
        c.dispose();
      }
    }
  }
}
