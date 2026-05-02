import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../bloc/nnc_play_bloc.dart';

/// Màn chơi cho game Nhanh Như Chớp.
///
/// Style đồng bộ với [pictogram_play/widgets/question_view.dart]:
///   - Header: timer pill (đổi màu khi còn ≤ 30s) + nút "Hoàn thành"
///   - Question navigator: card chứa list số câu cuộn ngang
///   - Question card + options list
///   - Bottom nav: "CÂU TRƯỚC" / "CÂU SAU"
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
        final timeStr = formatTime(state.remainingSeconds);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, state, timeStr),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildQuestionNavigator(context, state),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildQuestionCard(state.currentIndex, question.question),
                    const SizedBox(height: AppSpacing.md),
                    _buildOptionsList(context, state),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context, state),
          ],
        );
      },
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    NNCPlayInProgress state,
    String timeStr,
  ) {
    final isLow = state.remainingSeconds <= 30;
    final timerBg = isLow
        ? AppColors.destructive.withValues(alpha: 0.1)
        : AppColors.primaryLight;
    final timerBorder = isLow
        ? AppColors.destructive.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.2);
    final timerColor = isLow ? AppColors.destructive : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: timerBg,
              border: Border.all(color: timerBorder),
              borderRadius: AppBorders.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 20, color: timerColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  timeStr,
                  style: AppTypography.textXl.bold.copyWith(color: timerColor),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            height: 40,
            child: ElevatedButton(
              onPressed: () => context.read<NNCPlayBloc>().add(const EndGame()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeFull,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Hoàn thành'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Question navigator ─────────────────────────────────────────────────────

  Widget _buildQuestionNavigator(
    BuildContext context,
    NNCPlayInProgress state,
  ) {
    final total = state.questions.length;
    final answeredCount = state.userAnswers.where((a) => a != -1).length;
    final progress = total > 0 ? answeredCount / total : 0.0;
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
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
            'Danh sách câu hỏi',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          Text(
            'NHẤN ĐỂ CHUYỂN NHANH',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ─── Progress bar ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TIẾN ĐỘ HOÀN THÀNH',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$answeredCount/$total ($percent%)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppBorders.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.muted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // ─── Question chips ───
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(total, (i) {
              final isCurrent = i == state.currentIndex;
              final isAnswered = state.userAnswers[i] != -1;

              Color bgColor;
              Color textColor;
              if (isCurrent) {
                bgColor = AppColors.primary;
                textColor = Colors.white;
              } else if (isAnswered) {
                bgColor = AppColors.primary.withValues(alpha: 0.15);
                textColor = AppColors.primary;
              } else {
                bgColor = AppColors.muted;
                textColor = AppColors.foreground;
              }

              return Padding(
                padding: EdgeInsets.only(
                  right: i < total - 1 ? AppSpacing.xs : 0,
                ),
                child: GestureDetector(
                  onTap: () =>
                      context.read<NNCPlayBloc>().add(GoToQuestion(index: i)),
                  child: Container(
                    width: 40,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: AppBorders.borderRadiusSm,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.labelMedium.copyWith(
                        color: textColor,
                      ),
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

  // ── Question card ──────────────────────────────────────────────────────────

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
              color: AppColors.primaryLight,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Text(
              'CÂU HỎI ${index + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              questionText,
              style: AppTypography.h3.copyWith(color: AppColors.foreground),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Options list ───────────────────────────────────────────────────────────

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
              bottom: i < question.options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () =>
                  context.read<NNCPlayBloc>().add(SelectAnswer(optionIndex: i)),
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
                    color: isSelected ? AppColors.primary : AppColors.border,
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
                        color: isSelected ? AppColors.primary : AppColors.muted,
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
                      Icon(
                        LucideIcons.checkCircle,
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

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context, NNCPlayInProgress state) {
    final isFirst = state.currentIndex == 0;
    final isLast = state.currentIndex == state.questions.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.smMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: isFirst
                ? null
                : () =>
                      context.read<NNCPlayBloc>().add(const PreviousQuestion()),
            icon: const Icon(LucideIcons.chevronLeft, size: 20),
            label: const Text('CÂU TRƯỚC'),
            style: TextButton.styleFrom(
              foregroundColor: isFirst
                  ? AppColors.mutedForeground
                  : AppColors.primary,
            ),
          ),
          TextButton.icon(
            onPressed: isLast
                ? null
                : () => context.read<NNCPlayBloc>().add(const NextQuestion()),
            icon: const SizedBox.shrink(),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('CÂU SAU'),
                const Icon(LucideIcons.chevronRight, size: 20),
              ],
            ),
            style: TextButton.styleFrom(
              foregroundColor: isLast
                  ? AppColors.mutedForeground
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
