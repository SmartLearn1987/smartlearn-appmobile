import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/domain/entities/dictation_entity.dart';
import '../../domain/value_objects/dictation_result.dart';
import '../../domain/value_objects/word_comparison.dart';
import 'dictation_card.dart';

/// Hiển thị màn hình kết quả sau khi người dùng nộp bài chép chính tả.
///
/// Bố cục (cuộn dọc):
///   1. TIÊU ĐỀ      — card hiển thị tên bài
///   2. NỘI DUNG     — card hiển thị đoạn gốc, từ đúng (xanh) / sai (đỏ)
///   3. Chép chính tả * — card hiển thị phần user đã gõ (read-only, mờ)
///   4. Banner điểm   — trophy + % chính xác + nhận xét (đổi màu theo điểm)
///   5. Card chi tiết — tổng số từ / từ đúng / từ sai / thời gian + progress
///   6. Hành động     — "Thử lại" (outlined) + "Bài mới" (filled)
class DictationResultView extends StatelessWidget {
  const DictationResultView({
    required this.entity,
    required this.result,
    required this.wordComparisons,
    required this.userInput,
    required this.elapsedSeconds,
    required this.isLoadingNew,
    required this.onTryAgain,
    required this.onLoadNew,
    super.key,
  });

  final DictationEntity entity;
  final DictationResult result;
  final List<WordComparison> wordComparisons;
  final String userInput;
  final int elapsedSeconds;
  final bool isLoadingNew;
  final VoidCallback onTryAgain;
  final VoidCallback onLoadNew;

  @override
  Widget build(BuildContext context) {
    final accuracy = result.accuracy;
    final accuracyPercent = (accuracy * 100).round();
    final tier = _ResultTier.from(accuracy);
    final wrongWords = result.totalWords - result.correctWords;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.md,
        AppSpacing.mdLg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── TIÊU ĐỀ ───
          const DictationSectionLabel(label: 'TIÊU ĐỀ'),
          const SizedBox(height: AppSpacing.sm),
          DictationCard(
            child: Text(
              entity.title,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── NỘI DUNG (color-coded) ───
          const DictationSectionLabel(label: 'NỘI DUNG'),
          const SizedBox(height: AppSpacing.sm),
          DictationCard(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: _ColorCodedContent(comparisons: wordComparisons),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Chép chính tả * ───
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Chép chính tả ',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                TextSpan(
                  text: '*',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DictationCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              userInput.isEmpty ? '(Chưa nhập nội dung)' : userInput,
              style: AppTypography.bodyMedium.copyWith(
                color: userInput.isEmpty
                    ? AppColors.mutedForeground
                    : AppColors.mutedForeground,
                height: 1.6,
                fontStyle: userInput.isEmpty ? FontStyle.italic : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Banner điểm ───
          _ScoreBanner(percent: accuracyPercent, tier: tier),
          const SizedBox(height: AppSpacing.md),

          // ─── Card chi tiết ───
          _DetailCard(
            totalWords: result.totalWords,
            correctWords: result.correctWords,
            wrongWords: wrongWords,
            elapsedSeconds: elapsedSeconds,
            accuracy: accuracy,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Hành động ───
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onTryAgain,
                icon: const Icon(LucideIcons.refreshCcw, size: 18),
                label: const Text('Thử lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.foreground,
                  side: const BorderSide(color: AppColors.border),
                  shape: AppBorders.shapeFull,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.smMd,
                  ),
                  textStyle: AppTypography.buttonMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: isLoadingNew ? null : onLoadNew,
                icon: isLoadingNew
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
                label: const Text('Bài mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  disabledBackgroundColor: AppColors.muted,
                  disabledForegroundColor: AppColors.mutedForeground,
                  elevation: 0,
                  shape: AppBorders.shapeFull,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.smMd,
                  ),
                  textStyle: AppTypography.buttonMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color-coded content
// ─────────────────────────────────────────────────────────────────────────────

class _ColorCodedContent extends StatelessWidget {
  const _ColorCodedContent({required this.comparisons});

  final List<WordComparison> comparisons;

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return Text(
        '(Không có nội dung)',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
      );
    }

    final baseStyle = AppTypography.bodyMedium.copyWith(height: 1.9);

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: comparisons.map((c) {
        final color = c.isCorrect ? AppColors.success : AppColors.destructive;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppBorders.borderRadiusSm,
          ),
          child: Text(
            c.originalWord,
            style: baseStyle.copyWith(
              color: color,
              fontWeight: c.isCorrect ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score banner
// ─────────────────────────────────────────────────────────────────────────────

enum _ResultTier {
  excellent('Tuyệt vời 🎉'),
  good('Khá tốt 👍'),
  needPractice('Cần luyện thêm 📚');

  const _ResultTier(this.message);

  final String message;

  factory _ResultTier.from(double accuracy) {
    if (accuracy >= 0.8) return _ResultTier.excellent;
    if (accuracy >= 0.5) return _ResultTier.good;
    return _ResultTier.needPractice;
  }

  Color get color => switch (this) {
    _ResultTier.excellent => AppColors.success,
    _ResultTier.good => AppColors.warning,
    _ResultTier.needPractice => AppColors.destructive,
  };
}

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({required this.percent, required this.tier});

  final int percent;
  final _ResultTier tier;

  @override
  Widget build(BuildContext context) {
    final color = tier.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.trophy, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$percent%',
            style: AppTypography.h1.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tier.message,
            style: AppTypography.labelLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail card
// ─────────────────────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.totalWords,
    required this.correctWords,
    required this.wrongWords,
    required this.elapsedSeconds,
    required this.accuracy,
  });

  final int totalWords;
  final int correctWords;
  final int wrongWords;
  final int elapsedSeconds;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết kết quả',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _StatRow(label: 'Tổng số từ', value: '$totalWords từ'),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            label: 'Từ đúng',
            value: '$correctWords từ',
            valueColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            label: 'Từ sai',
            value: '$wrongWords từ',
            valueColor: AppColors.destructive,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            icon: LucideIcons.clock,
            label: 'Thời gian',
            value: _formatDuration(elapsedSeconds),
            valueColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.smMd),
          ClipRRect(
            borderRadius: AppBorders.borderRadiusFull,
            child: LinearProgressIndicator(
              value: accuracy.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.muted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: valueColor ?? AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
