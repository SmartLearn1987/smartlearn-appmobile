import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/nnc_play_bloc.dart';

class NNCQuestionView extends StatelessWidget {
  const NNCQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NNCPlayBloc, NNCPlayState>(
      builder: (context, state) {
        if (state is! NNCPlayInProgress) {
          return const SizedBox.shrink();
        }

        final question = state.questions[state.currentIndex];
        final total = state.questions.length;
        final answeredPercent = calculateAnsweredPercentage(state.userAnswers);
        final answeredCount =
            state.userAnswers.where((a) => a != -1).length;

        return Column(
          children: [
            // ─── Header ───
            _buildHeader(context, state),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Scrollable content ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ─── Question Card ───
                    _buildQuestionCard(
                      state.currentIndex,
                      question.question,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Options List ───
                    _buildOptionsList(context, state),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Progress Sidebar ───
                    _buildProgressSidebar(
                      context,
                      state,
                      answeredPercent,
                      answeredCount,
                      total,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // ─── Question Navigator ───
            _buildQuestionNavigator(context, state),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Header
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, NNCPlayInProgress state) {
    final timeStr = formatTime(state.remainingSeconds);
    final progressStr =
        formatProgress(state.currentIndex, state.questions.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(
                    'Nhanh như chớp',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  Text(
                    progressStr.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Badge "Tia chớp X"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: AppBorders.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Tia chớp ${state.currentIndex + 1}',
                  style:
                      AppTypography.labelMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Timer badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppBorders.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  timeStr,
                  style:
                      AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Kết thúc button
          SizedBox(
            width: 140,
            height: 36,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<NNCPlayBloc>().add(const EndGame()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeFull,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Kết thúc'),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Question Card
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildQuestionCard(int index, String questionText) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Text(
              'CÂU HỎI ${index + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              questionText,
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Options List
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildOptionsList(BuildContext context, NNCPlayInProgress state) {
    final question = state.questions[state.currentIndex];
    final selectedIndex = state.userAnswers[state.currentIndex];
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: List.generate(question.options.length, (i) {
          final isSelected = selectedIndex == i;
          final letter = i < letters.length ? letters[i] : '${i + 1}';

          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  i < question.options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => context
                  .read<NNCPlayBloc>()
                  .add(SelectAnswer(optionIndex: i)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.smMd,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.card,
                  borderRadius: AppBorders.borderRadiusMd,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected
                        ? AppBorders.widthThick
                        : AppBorders.widthThin,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Text(
                        question.options[i],
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.foreground,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Progress Sidebar
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildProgressSidebar(
    BuildContext context,
    NNCPlayInProgress state,
    double answeredPercent,
    int answeredCount,
    int total,
  ) {
    final percent = (answeredPercent * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến trình tia chớp',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          Text(
            'Phản xạ nhanh!',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$answeredCount/$total ($percent%)',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: AppBorders.borderRadiusFull,
                child: LinearProgressIndicator(
                  value: answeredPercent,
                  minHeight: 8,
                  backgroundColor: AppColors.muted,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smMd),
          // Numbered button grid
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(total, (i) {
              final isCurrent = i == state.currentIndex;
              final isAnswered = state.userAnswers[i] != -1;

              Color bgColor;
              Color textColor;
              double size;

              if (isCurrent) {
                bgColor = AppColors.primary;
                textColor = Colors.white;
                size = 40;
              } else if (isAnswered) {
                bgColor = AppColors.primary.withValues(alpha: 0.15);
                textColor = AppColors.primary;
                size = 36;
              } else {
                bgColor = AppColors.muted;
                textColor = AppColors.mutedForeground;
                size = 36;
              }

              return GestureDetector(
                onTap: () => context
                    .read<NNCPlayBloc>()
                    .add(GoToQuestion(index: i)),
                child: Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppBorders.borderRadiusSm,
                  ),
                  child: isAnswered && !isCurrent
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 16,
                        )
                      : Text(
                          '${i + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: textColor,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Question Navigator
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildQuestionNavigator(
    BuildContext context,
    NNCPlayInProgress state,
  ) {
    final isFirst = state.currentIndex == 0;
    final isLast = state.currentIndex == state.questions.length - 1;
    final total = state.questions.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.smMd,
      ),
      child: Column(
        children: [
          // Dot indicators
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final isCurrent = i == state.currentIndex;
                return GestureDetector(
                  onTap: () => context
                      .read<NNCPlayBloc>()
                      .add(GoToQuestion(index: i)),
                  child: Container(
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isCurrent ? AppColors.primary : AppColors.muted,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: isFirst
                    ? null
                    : () => context
                        .read<NNCPlayBloc>()
                        .add(const PreviousQuestion()),
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Câu trước'),
                style: TextButton.styleFrom(
                  foregroundColor: isFirst
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
              TextButton.icon(
                onPressed: isLast
                    ? null
                    : () => context
                        .read<NNCPlayBloc>()
                        .add(const NextQuestion()),
                icon: const Text(''),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Câu sau'),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isLast
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
