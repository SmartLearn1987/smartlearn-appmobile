import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/quizlet_term_entity.dart';
import '../bloc/quizlet_detail/quizlet_detail_bloc.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/quizlet_study_widgets.dart';

class QuizletDetailPage extends StatelessWidget {
  const QuizletDetailPage({required this.quizletId, super.key});

  final String quizletId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizletDetailBloc>(
      create: (_) =>
          getIt<QuizletDetailBloc>()
            ..add(LoadQuizletDetail(quizletId: quizletId)),
      child: const _QuizletDetailView(),
    );
  }
}

class _QuizletDetailView extends StatelessWidget {
  const _QuizletDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: BlocBuilder<QuizletDetailBloc, QuizletDetailState>(
          buildWhen: (prev, curr) =>
              curr is QuizletDetailLoaded ||
              curr is QuizletDetailLoading ||
              curr is QuizletDetailError,
          builder: (context, state) {
            if (state is QuizletDetailLoaded) {
              return Text(
                state.detail.title,
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
                overflow: TextOverflow.ellipsis,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<QuizletDetailBloc, QuizletDetailState>(
          buildWhen: (prev, curr) =>
              curr is QuizletDetailLoading ||
              curr is QuizletDetailLoaded ||
              curr is QuizletDetailError,
          builder: (context, state) => switch (state) {
            QuizletDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            QuizletDetailLoaded() => _LoadedContent(state: state),
            QuizletDetailError(:final message) => _ErrorContent(
              message: message,
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _LoadedContent extends StatefulWidget {
  const _LoadedContent({required this.state});

  final QuizletDetailLoaded state;

  @override
  State<_LoadedContent> createState() => _LoadedContentState();
}

class _LoadedContentState extends State<_LoadedContent> {
  late int _currentIndex;
  late bool _isFlipped;
  StudyMode _mode = StudyMode.flashcard;
  bool _isAutoPlaying = false;
  bool _isShuffled = false;
  late List<int> _order;
  final TextEditingController _answerController = TextEditingController();
  Timer? _autoPlayTimer;

  List<QuizletTermEntity> terms() => widget.state.detail.terms;

  List<QuizletTermEntity> displayTerms() =>
      _order.map((index) => terms()[index]).toList();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.state.currentIndex;
    _isFlipped = widget.state.isFlipped;
    _order = List<int>.generate(terms().length, (i) => i);
  }

  @override
  void didUpdateWidget(covariant _LoadedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.detail.id != widget.state.detail.id ||
        oldWidget.state.detail.terms.length !=
            widget.state.detail.terms.length) {
      _currentIndex = 0;
      _isFlipped = false;
      _isAutoPlaying = false;
      _isShuffled = false;
      _mode = StudyMode.flashcard;
      _order = List<int>.generate(terms().length, (i) => i);
      _answerController.clear();
      _stopAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _answerController.dispose();
    super.dispose();
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _toggleAutoPlay() {
    if (_isAutoPlaying) {
      setState(() {
        _isAutoPlaying = false;
      });
      _stopAutoPlay();
      return;
    }

    if (displayTerms().isEmpty) {
      return;
    }

    setState(() {
      _isAutoPlaying = true;
    });
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || displayTerms().isEmpty) {
        return;
      }
      setState(() {
        _currentIndex = (_currentIndex + 1) % displayTerms().length;
        _isFlipped = _mode == StudyMode.back;
        _answerController.clear();
      });
    });
  }

  void _setMode(StudyMode mode) {
    setState(() {
      _mode = mode;
      _answerController.clear();
      if (_mode == StudyMode.back) {
        _isFlipped = true;
      } else {
        _isFlipped = false;
      }
    });
  }

  void _toggleShuffle() {
    final count = terms().length;
    if (count <= 1) {
      return;
    }

    setState(() {
      if (_isShuffled) {
        _order = List<int>.generate(count, (i) => i);
        _isShuffled = false;
      } else {
        final random = Random();
        _order = List<int>.generate(count, (i) => i)..shuffle(random);
        _isShuffled = true;
      }
      _currentIndex = 0;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
      _isAutoPlaying = false;
    });
    _stopAutoPlay();
  }

  void _goNext() {
    if (_currentIndex >= displayTerms().length - 1) {
      return;
    }
    setState(() {
      _currentIndex += 1;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
    });
  }

  void _goPrevious() {
    if (_currentIndex <= 0) {
      return;
    }
    setState(() {
      _currentIndex -= 1;
      _isFlipped = _mode == StudyMode.back;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    if (displayTerms().isEmpty) {
      return;
    }
    final term = displayTerms()[_currentIndex];
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
    final terms = displayTerms();
    if (terms.isEmpty) {
      return Center(
        child: Text(
          'Học phần chưa có thẻ',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      );
    }

    final currentIndex = _currentIndex;
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == terms.length - 1;
    final currentTerm = terms[currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          StudyModeTabs(value: _mode, onChanged: _setMode),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -200 && !isLast) {
                  _goNext();
                } else if (velocity > 200 && !isFirst) {
                  _goPrevious();
                }
              },
              child: _buildCardByMode(context, currentTerm),
            ),
          ),
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
                    '${currentIndex + 1} / ${terms.length}',
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
              const SizedBox(width: 96),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildCardByMode(BuildContext context, QuizletTermEntity term) {
    if (_mode == StudyMode.practice) {
      return PracticeStudyCard(term: term);
    }

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

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                final page = context
                    .findAncestorWidgetOfExactType<QuizletDetailPage>();
                if (page != null) {
                  context.read<QuizletDetailBloc>().add(
                    LoadQuizletDetail(quizletId: page.quizletId),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                textStyle: AppTypography.buttonMedium,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
