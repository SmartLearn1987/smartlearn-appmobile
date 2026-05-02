import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/entities/learning_question_entity.dart';
import '../bloc/hcb_play_bloc.dart';
import '../widgets/control_bar_widget.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/progress_indicator_widget.dart';

class HCBPlayScreen extends StatelessWidget {
  const HCBPlayScreen({
    required this.questions,
    required this.generalQuestion,
    required this.categoryName,
    super.key,
  });

  final List<LearningQuestionEntity> questions;
  final String generalQuestion;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HCBPlayBloc()
        ..add(
          StartGame(questions: questions, generalQuestion: generalQuestion),
        ),
      child: _HCBPlayView(categoryName: categoryName),
    );
  }
}

class _HCBPlayView extends StatelessWidget {
  const _HCBPlayView({required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(categoryName),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HCBPlayBloc, HCBPlayState>(
          builder: (context, state) => switch (state) {
            HCBInitial() => const SizedBox.shrink(),
            HCBLoading() => const _HCBLoadingView(),
            HCBInProgress() => _HCBInProgressView(state: state),
            HCBError() => _HCBErrorView(message: state.message),
          },
        ),
      ),
    );
  }
}

// ─── Loading View ────────────────────────────────────────────────────────

class _HCBLoadingView extends StatefulWidget {
  const _HCBLoadingView();

  @override
  State<_HCBLoadingView> createState() => _HCBLoadingViewState();
}

class _HCBLoadingViewState extends State<_HCBLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(
              LucideIcons.bookOpen,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'ĐANG CHUẨN BỊ THẺ HỌC...',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── In Progress View ────────────────────────────────────────────────────

class _HCBInProgressView extends StatelessWidget {
  const _HCBInProgressView({required this.state});

  final HCBInProgress state;

  @override
  Widget build(BuildContext context) {
    final question = state.questions[state.currentIndex];

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        // Progress indicator
        HCBProgressIndicatorWidget(
          currentIndex: state.currentIndex,
          total: state.questions.length,
        ),
        const SizedBox(height: AppSpacing.md),
        // Flashcard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
            child: FlashcardWidget(
              imageUrl: question.imageUrl,
              generalQuestion: state.generalQuestion,
              answer: question.answer,
              isFlipped: state.isFlipped,
              onFlip: () => context.read<HCBPlayBloc>().add(const FlipCard()),
            ),
          ),
        ),
        // Control bar
        ControlBarWidget(
          currentIndex: state.currentIndex,
          totalCount: state.questions.length,
          isAutoPlaying: state.isAutoPlaying,
          onPrevious: () =>
              context.read<HCBPlayBloc>().add(const PreviousCard()),
          onNext: () => context.read<HCBPlayBloc>().add(const NextCard()),
          onToggleAutoPlay: () =>
              context.read<HCBPlayBloc>().add(const ToggleAutoPlay()),
          onShuffle: () =>
              context.read<HCBPlayBloc>().add(const ShuffleCards()),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─── Error View ──────────────────────────────────────────────────────────

class _HCBErrorView extends StatelessWidget {
  const _HCBErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.destructive,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
