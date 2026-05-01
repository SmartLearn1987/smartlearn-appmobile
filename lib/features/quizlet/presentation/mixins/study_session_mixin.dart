import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/quizlet_study_widgets.dart';

/// Mixin chứa toàn bộ state và logic cho một phiên học flashcard.
///
/// Dùng chung cho [_LoadedContentState] (detail page) và
/// [QuizletFullscreenPageState] (fullscreen page).
///
/// Class sử dụng mixin phải:
/// - Là [State] của một [StatefulWidget]
/// - Cung cấp [allTerms] — danh sách gốc chưa shuffle
mixin StudySessionMixin<T extends StatefulWidget> on State<T> {
  // ── Abstract ──────────────────────────────────────────────────────────────

  /// Danh sách thẻ gốc (chưa shuffle).
  List<QuizletTermEntity> get allTerms;

  // ── State ─────────────────────────────────────────────────────────────────

  int currentIndex = 0;
  bool isFlipped = false;
  StudyMode mode = StudyMode.flashcard;
  bool isAutoPlaying = false;
  bool isShuffled = false;
  late List<int> order;
  final answerController = TextEditingController();
  Timer? _autoPlayTimer;

  List<QuizletTermEntity> get displayTerms =>
      order.map((i) => allTerms[i]).toList();

  // ── Init / Dispose ────────────────────────────────────────────────────────

  void initSession({
    int initialIndex = 0,
    bool initialFlipped = false,
    StudyMode initialMode = StudyMode.flashcard,
    bool initialShuffled = false,
    List<int>? initialOrder,
  }) {
    currentIndex = initialIndex;
    isFlipped = initialFlipped;
    mode = initialMode;
    isShuffled = initialShuffled;
    order = initialOrder ?? List<int>.generate(allTerms.length, (i) => i);
  }

  void resetSession() {
    currentIndex = 0;
    isFlipped = false;
    isAutoPlaying = false;
    isShuffled = false;
    mode = StudyMode.flashcard;
    order = List<int>.generate(allTerms.length, (i) => i);
    answerController.clear();
    stopAutoPlay();
  }

  void disposeSession() {
    stopAutoPlay();
    answerController.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void goNext() {
    if (currentIndex >= displayTerms.length - 1) return;
    setState(() {
      currentIndex++;
      isFlipped = mode == StudyMode.back;
      answerController.clear();
    });
  }

  void goPrevious() {
    if (currentIndex <= 0) return;
    setState(() {
      currentIndex--;
      isFlipped = mode == StudyMode.back;
      answerController.clear();
    });
  }

  // ── Mode ──────────────────────────────────────────────────────────────────

  void setMode(StudyMode newMode) {
    setState(() {
      mode = newMode;
      isFlipped = newMode == StudyMode.back;
      answerController.clear();
    });
  }

  // ── Shuffle ───────────────────────────────────────────────────────────────

  void toggleShuffle() {
    if (allTerms.length <= 1) return;
    setState(() {
      if (isShuffled) {
        order = List<int>.generate(allTerms.length, (i) => i);
        isShuffled = false;
      } else {
        order = List<int>.generate(allTerms.length, (i) => i)
          ..shuffle(Random());
        isShuffled = true;
      }
      currentIndex = 0;
      isFlipped = mode == StudyMode.back;
      answerController.clear();
      isAutoPlaying = false;
    });
    stopAutoPlay();
  }

  // ── Auto-play ─────────────────────────────────────────────────────────────

  void toggleAutoPlay() {
    if (isAutoPlaying) {
      stopAutoPlay();
      setState(() => isAutoPlaying = false);
      return;
    }
    if (displayTerms.isEmpty) return;
    setState(() => isAutoPlaying = true);
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        currentIndex = (currentIndex + 1) % displayTerms.length;
        isFlipped = mode == StudyMode.back;
        answerController.clear();
      });
    });
  }

  void stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // ── Answer check ──────────────────────────────────────────────────────────

  void checkAnswer() {
    if (displayTerms.isEmpty) return;
    final term = displayTerms[currentIndex];
    final expected = mode == StudyMode.front ? term.definition : term.term;
    final isCorrect =
        answerController.text.trim().toLowerCase() ==
        expected.trim().toLowerCase();
    if (isCorrect) {
      AppToast.success(context, 'Chính xác');
    } else {
      AppToast.error(context, 'Chưa chính xác');
    }
  }
}
