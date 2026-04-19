import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/cdtn_play_bloc.dart';

class CDTNQuestionView extends StatelessWidget {
  const CDTNQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CDTNPlayBloc, CDTNPlayState>(
      builder: (context, state) {
        if (state is! CDTNPlayInProgress) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // ─── Header ───
            _buildHeader(context, state),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Sidebar (Question Grid) ───
            _buildQuestionSidebar(context, state),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Scrollable content ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ─── Instruction ───
                    _buildInstruction(),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Draggable Word Area ───
                    _buildDraggableWordArea(context, state),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Check Button ───
                    _buildCheckButton(context),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Feedback ───
                    if (state.checkStatus != null)
                      _buildFeedback(state.checkStatus!),

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

  Widget _buildHeader(BuildContext context, CDTNPlayInProgress state) {
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
              const Text('📜', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(
                    'Ca dao tục ngữ',
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
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  timeStr,
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Hoàn thành button
          SizedBox(
            width: 140,
            height: 36,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<CDTNPlayBloc>().add(const EndGame()),
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

  // ───────────────────────────────────────────────────────────────────────
  // Question Sidebar
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildQuestionSidebar(
    BuildContext context,
    CDTNPlayInProgress state,
  ) {
    final total = state.questions.length;

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
          // Numbered button grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(total, (i) {
                final isCurrent = i == state.currentIndex;
                // Determine real-time correctness via checkWordOrder
                final isCorrect = CDTNPlayBloc.checkWordOrder(
                  state.userWordArrangements[i],
                  state.questions[i].content,
                );

                Color bgColor;
                Color textColor;
                List<BoxShadow>? shadow;
                Border? itemBorder;

                if (isCurrent) {
                  // Emerald + shadow for current question
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                  shadow = const [
                    BoxShadow(
                      color: Color(0x332D9B63),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ];
                } else if (isCorrect) {
                  // Green-50 + green border for correct
                  bgColor = AppColors.success.withValues(alpha: 0.15);
                  textColor = AppColors.success;
                  itemBorder = Border.all(
                    color: AppColors.success,
                    width: AppBorders.widthThin,
                  );
                } else {
                  // Muted for incorrect / unanswered
                  bgColor = AppColors.muted;
                  textColor = AppColors.mutedForeground;
                }

                return Padding(
                  padding: EdgeInsets.only(
                    right: i < total - 1 ? AppSpacing.xs : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => context
                        .read<CDTNPlayBloc>()
                        .add(GoToQuestion(index: i)),
                    child: Container(
                      width: 40,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: AppBorders.borderRadiusSm,
                        boxShadow: shadow,
                        border: itemBorder,
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
          ),
          const SizedBox(height: AppSpacing.sm),
          // Info box with instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Kéo thả các từ để ghép thành câu đúng. '
                    'Bạn có thể kiểm tra từng câu và làm lại nếu sai.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Instruction
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildInstruction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.smMd),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusMd,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
        ),
        child: Text(
          'Sắp xếp các từ để tạo thành câu đúng',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.foreground,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Draggable Word Area
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildDraggableWordArea(
    BuildContext context,
    CDTNPlayInProgress state,
  ) {
    final currentWords = state.userWordArrangements[state.currentIndex];

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
              'CÂU HỎI ${state.currentIndex + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Material(
                  elevation: 4,
                  borderRadius: AppBorders.borderRadiusSm,
                  color: Colors.transparent,
                  child: child,
                ),
                child: child,
              );
            },
            itemCount: currentWords.length,
            itemBuilder: (context, index) {
              final wordItem = currentWords[index];
              return ReorderableDragStartListener(
                key: ValueKey(wordItem.id),
                index: index,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.smMd,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppBorders.borderRadiusSm,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: AppBorders.widthThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_handle,
                        size: 20,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          wordItem.word,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              context.read<CDTNPlayBloc>().add(
                    ReorderWords(oldIndex: oldIndex, newIndex: newIndex),
                  );
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Check Button
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildCheckButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () =>
              context.read<CDTNPlayBloc>().add(const CheckAnswer()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: AppBorders.shapeSm,
          ),
          child: const Text('Kiểm tra'),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Feedback
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildFeedback(CheckStatus status) {
    final isCorrect = status == CheckStatus.correct;
    final color = isCorrect ? AppColors.success : AppColors.destructive;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: color, width: AppBorders.widthThin),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isCorrect ? 'Chính xác!' : 'Chưa chính xác',
            style: AppTypography.labelLarge.copyWith(color: color),
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
    CDTNPlayInProgress state,
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
                      .read<CDTNPlayBloc>()
                      .add(GoToQuestion(index: i)),
                  child: Container(
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? AppColors.primary : AppColors.muted,
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
                        .read<CDTNPlayBloc>()
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
                        .read<CDTNPlayBloc>()
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
