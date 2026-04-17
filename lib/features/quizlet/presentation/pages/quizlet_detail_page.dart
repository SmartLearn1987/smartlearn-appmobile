import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/quizlet_detail/quizlet_detail_bloc.dart';
import '../widgets/flashcard_widget.dart';

class QuizletDetailPage extends StatelessWidget {
  const QuizletDetailPage({required this.quizletId, super.key});

  final String quizletId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizletDetailBloc>(
      create: (_) => getIt<QuizletDetailBloc>()
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
      body: BlocBuilder<QuizletDetailBloc, QuizletDetailState>(
        buildWhen: (prev, curr) =>
            curr is QuizletDetailLoading ||
            curr is QuizletDetailLoaded ||
            curr is QuizletDetailError,
        builder: (context, state) => switch (state) {
          QuizletDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          QuizletDetailLoaded() => _LoadedContent(state: state),
          QuizletDetailError(:final message) =>
            _ErrorContent(message: message),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.state});

  final QuizletDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final terms = state.detail.terms;
    final currentIndex = state.currentIndex;
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == terms.length - 1;
    final progress = terms.isNotEmpty
        ? (currentIndex + 1) / terms.length
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.muted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: AppSpacing.xs,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Card index indicator
          Text(
            '${currentIndex + 1}/${terms.length}',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Flashcard with swipe gesture
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -200 && !isLast) {
                  context
                      .read<QuizletDetailBloc>()
                      .add(const NextCard());
                } else if (velocity > 200 && !isFirst) {
                  context
                      .read<QuizletDetailBloc>()
                      .add(const PreviousCard());
                }
              },
              child: FlashcardWidget(
                term: terms[currentIndex],
                isFlipped: state.isFlipped,
                onFlip: () => context
                    .read<QuizletDetailBloc>()
                    .add(const FlipCard()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isFirst
                      ? null
                      : () => context
                            .read<QuizletDetailBloc>()
                            .add(const PreviousCard()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.foreground,
                    disabledBackgroundColor:
                        AppColors.muted.withValues(alpha: 0.5),
                    disabledForegroundColor:
                        AppColors.mutedForeground.withValues(alpha: 0.5),
                    textStyle: AppTypography.buttonMedium,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.smMd,
                    ),
                  ),
                  child: const Text('Trước'),
                ),
              ),
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLast
                      ? null
                      : () => context
                            .read<QuizletDetailBloc>()
                            .add(const NextCard()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    disabledForegroundColor:
                        AppColors.primaryForeground.withValues(alpha: 0.5),
                    textStyle: AppTypography.buttonMedium,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.smMd,
                    ),
                  ),
                  child: const Text('Tiếp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
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
