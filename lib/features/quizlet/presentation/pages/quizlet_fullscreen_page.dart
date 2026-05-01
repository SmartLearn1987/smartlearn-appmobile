import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/flashcard_widget.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/quizlet_study_widgets.dart';

class QuizletFullscreenPage extends StatefulWidget {
  const QuizletFullscreenPage({
    super.key,
    required this.terms,
    required this.initialIndex,
    required this.initialMode,
    required this.isShuffled,
    required this.order,
  });

  final List<QuizletTermEntity> terms;
  final int initialIndex;
  final StudyMode initialMode;
  final bool isShuffled;
  final List<int> order;

  @override
  State<QuizletFullscreenPage> createState() => QuizletFullscreenPageState();
}

class QuizletFullscreenPageState extends State<QuizletFullscreenPage> {
  late int _currentIndex;
  late bool _isFlipped;
  late StudyMode _mode;
  late List<int> _order;
  bool _isShuffled = false;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;
  final TextEditingController _answerController = TextEditingController();

  List<QuizletTermEntity> get _displayTerms =>
      _order.map((i) => widget.terms[i]).toList();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _mode = widget.initialMode;
    _order = List.of(widget.order);
    _isShuffled = widget.isShuffled;
    _isFlipped = _mode == StudyMode.back;
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex >= _displayTerms.length - 1) return;
    setState(() {
      _currentIndex++;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
    });
  }

  void _goPrevious() {
    if (_currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
    });
  }

  void _toggleAutoPlay() {
    if (_isAutoPlaying) {
      _autoPlayTimer?.cancel();
      setState(() => _isAutoPlaying = false);
      return;
    }
    if (_displayTerms.isEmpty) return;
    setState(() => _isAutoPlaying = true);
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _displayTerms.length;
        _isFlipped = _mode == StudyMode.back;
        _answerController.clear();
      });
    });
  }

  void _toggleShuffle() {
    setState(() {
      if (_isShuffled) {
        _order = List<int>.generate(widget.terms.length, (i) => i);
        _isShuffled = false;
      } else {
        _order = List<int>.generate(widget.terms.length, (i) => i)
          ..shuffle(Random());
        _isShuffled = true;
      }
      _currentIndex = 0;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    final term = _displayTerms[_currentIndex];
    final expected = _mode == StudyMode.front ? term.definition : term.term;
    final isCorrect =
        _answerController.text.trim().toLowerCase() ==
        expected.trim().toLowerCase();
    if (isCorrect) {
      AppToast.success(context, 'Chính xác');
    } else {
      AppToast.error(context, 'Chưa chính xác');
    }
  }

  @override
  Widget build(BuildContext context) {
    final terms = _displayTerms;
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == terms.length - 1;
    final currentTerm = terms[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingCard,
          child: Column(
            children: [
              Expanded(child: _buildCardByMode(context, currentTerm)),
              if (_mode == StudyMode.front || _mode == StudyMode.back) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _answerController,
                        hintText: 'Nhập đáp án...',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _checkAnswer(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      child: const Text('Kiểm tra'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleAutoPlay,
                        icon: Icon(
                          _isAutoPlaying ? LucideIcons.pause : LucideIcons.play,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleShuffle,
                        icon: Icon(
                          LucideIcons.shuffle,
                          color: _isShuffled ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: isFirst ? null : _goPrevious,
                        icon: const Icon(LucideIcons.chevronLeft),
                      ),
                      Text(
                        '${_currentIndex + 1} / ${terms.length}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: isLast ? null : _goNext,
                        icon: const Icon(LucideIcons.chevronRight),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 48),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(LucideIcons.minimize2),
                        tooltip: 'Thoát',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardByMode(BuildContext context, QuizletTermEntity term) {
    if (_mode == StudyMode.practice) return PracticeStudyCard(term: term);
    if (_mode == StudyMode.front) {
      return SingleFaceStudyCard(
        text: term.term,
        textColor: AppColors.destructive,
      );
    }
    if (_mode == StudyMode.back) {
      return SingleFaceStudyCard(
        text: term.definition,
        textColor: Colors.blue.shade700,
      );
    }
    return FlashcardWidget(
      term: term,
      isFlipped: _isFlipped,
      onFlip: () => setState(() => _isFlipped = !_isFlipped),
    );
  }
}
