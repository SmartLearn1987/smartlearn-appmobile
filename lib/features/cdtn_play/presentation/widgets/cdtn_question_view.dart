import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/word_item.dart';
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildQuestionSidebar(context, state),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildArrangementCard(context, state),
                    const SizedBox(height: AppSpacing.md),
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

  Widget _buildQuestionSidebar(BuildContext context, CDTNPlayInProgress state) {
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
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
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
                  onTap: () =>
                      context.read<CDTNPlayBloc>().add(GoToQuestion(index: i)),
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
                    'Click vào các từ để ghép thành câu đúng. Bạn có thể kiểm tra từng câu và làm lại nếu sai.',
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
  // Arrangement Card (pool + answer slot + check button)
  // ───────────────────────────────────────────────────────────────────────

  Widget _buildArrangementCard(BuildContext context, CDTNPlayInProgress state) {
    final pool = state.poolFor(state.currentIndex);
    final selected = state.userWordArrangements[state.currentIndex];
    final canCheck = selected.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary.withValues(alpha: 0.4),
          strokeWidth: 1.5,
          dashWidth: 6,
          dashGap: 4,
          radius: AppBorders.radiusXl,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _buildTitleBadge(),
              const SizedBox(height: AppSpacing.sm),
              _buildHintRow(),
              const SizedBox(height: AppSpacing.lg),
              _buildPool(context, pool),
              const SizedBox(height: AppSpacing.lg),
              _buildAnswerSlot(context, selected),
              const SizedBox(height: AppSpacing.lg),
              _buildCheckButton(context, enabled: canCheck),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppBorders.borderRadiusFull,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: AppBorders.widthThin,
        ),
      ),
      child: Text(
        'SẮP XẾP CÁC TỪ ĐỂ TẠO THÀNH CÂU ĐÚNG',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHintRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.info, size: 14, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Click vào từng từ để chuyển xuống ô trống',
          style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  /// Pool: các từ chưa chọn — pill xanh đậm. Tap → chuyển xuống slot đáp án.
  Widget _buildPool(BuildContext context, List<WordItem> pool) {
    if (pool.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.smMd,
      runSpacing: AppSpacing.smMd,
      children: [
        for (final w in pool)
          _WordChip(
            label: w.word,
            filled: true,
            onTap: () =>
                context.read<CDTNPlayBloc>().add(SelectWord(wordId: w.id)),
          ),
      ],
    );
  }

  /// Slot đáp án: viền nét đứt; tap pill → trả từ về pool.
  Widget _buildAnswerSlot(BuildContext context, List<WordItem> selected) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.border,
        strokeWidth: 1.5,
        dashWidth: 5,
        dashGap: 4,
        radius: AppBorders.radiusXl,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.all(AppSpacing.md),
        alignment: Alignment.center,
        child: selected.isEmpty
            ? Text(
                'Ô trống — chọn từ ở trên',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.smMd,
                runSpacing: AppSpacing.smMd,
                children: [
                  for (final w in selected)
                    _WordChip(
                      label: w.word,
                      filled: false,
                      onTap: () => context.read<CDTNPlayBloc>().add(
                        UnselectWord(wordId: w.id),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildCheckButton(BuildContext context, {required bool enabled}) {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: enabled
            ? () => context.read<CDTNPlayBloc>().add(const CheckAnswer())
            : null,
        icon: const Icon(LucideIcons.check, size: 18),
        label: const Text('Kiểm tra'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.muted,
          disabledForegroundColor: AppColors.mutedForeground,
          shape: AppBorders.shapeFull,
          elevation: 0,
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
                : () => context.read<CDTNPlayBloc>().add(
                    const PreviousQuestion(),
                  ),
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Câu trước'),
            style: TextButton.styleFrom(
              foregroundColor: isFirst
                  ? AppColors.mutedForeground
                  : AppColors.primary,
            ),
          ),
          TextButton.icon(
            onPressed: isLast
                ? null
                : () => context.read<CDTNPlayBloc>().add(const NextQuestion()),
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
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _WordChip — pill hiển thị một từ.
//   - filled: true  → nền primary, chữ trắng (dùng cho pool).
//   - filled: false → viền primary, chữ primary (dùng cho slot đáp án).
// ─────────────────────────────────────────────────────────────────────────

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.primary : AppColors.card;
    final border = filled
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.4);
    final fg = filled ? Colors.white : AppColors.primary;

    return Material(
      color: bg,
      borderRadius: AppBorders.borderRadiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.borderRadiusXl,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
          decoration: BoxDecoration(
            borderRadius: AppBorders.borderRadiusXl,
            border: Border.all(color: border, width: AppBorders.widthMedium),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// _DashedBorderPainter — vẽ viền nét đứt bo góc cho RRect bao quanh child.
// ─────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.radius = 16,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(path), paint);
  }

  Path _dashPath(Path source) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dest.addPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      dashWidth != old.dashWidth ||
      dashGap != old.dashGap ||
      radius != old.radius;
}
