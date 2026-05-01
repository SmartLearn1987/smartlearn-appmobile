import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/value_objects/dictation_result.dart';
import '../../domain/value_objects/word_comparison.dart';

/// Displays the dictation game result after the user submits their answer.
///
/// Shows:
/// - Accuracy percentage prominently (e.g., "85%") with correctWords/totalWords
/// - Original content with color-coded words: green (correct) / red (incorrect)
/// - User's typed content for comparison
/// - "Chơi lại" (Play Again) and "Về trang chủ" (Go Home) buttons
class DictationResultView extends StatelessWidget {
  const DictationResultView({
    required this.result,
    required this.wordComparisons,
    required this.userInput,
    required this.onPlayAgain,
    required this.onGoHome,
    super.key,
  });

  /// The dictation result containing accuracy and word counts.
  final DictationResult result;

  /// Per-word comparison data for color-coding original content.
  final List<WordComparison> wordComparisons;

  /// The user's typed content.
  final String userInput;

  /// Callback when the user taps "Chơi lại".
  final VoidCallback onPlayAgain;

  /// Callback when the user taps "Về trang chủ".
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = (result.accuracy * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorders.borderRadiusFull,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Kết quả',
              style: AppTypography.h2.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Accuracy percentage card
            _AccuracyCard(
              accuracyPercent: accuracyPercent,
              correctWords: result.correctWords,
              totalWords: result.totalWords,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Original content with color-coded words
            _ContentSection(
              title: 'Nội dung gốc',
              child: _ColorCodedOriginalContent(
                wordComparisons: wordComparisons,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // User's typed content
            _ContentSection(
              title: 'Nội dung bạn đã gõ',
              child: Text(
                userInput.isEmpty ? '(Trống)' : userInput,
                style: AppTypography.bodyLarge.copyWith(
                  color: userInput.isEmpty
                      ? AppColors.mutedForeground
                      : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Play Again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPlayAgain,
                style: AppButtonStyles.primary,
                child: Text(
                  'Chơi lại',
                  style: AppTypography.buttonLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),

            // Go Home button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onGoHome,
                style: AppButtonStyles.outline,
                child: Text(
                  'Về trang chủ',
                  style: AppTypography.buttonLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays accuracy percentage and correct/total word counts.
class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({
    required this.accuracyPercent,
    required this.correctWords,
    required this.totalWords,
  });

  final int accuracyPercent;
  final int correctWords;
  final int totalWords;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Tỷ lệ chính xác',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$accuracyPercent%',
            style: AppTypography.h1.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            color: AppColors.border,
            height: AppBorders.widthThin,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Số từ đúng',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$correctWords/$totalWords',
            style: AppTypography.h3.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// A labeled section container for content display.
class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
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
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Renders original content with color-coded words using [RichText].
///
/// Correct words are displayed in [AppColors.success] (green),
/// incorrect words in [AppColors.destructive] (red).
class _ColorCodedOriginalContent extends StatelessWidget {
  const _ColorCodedOriginalContent({
    required this.wordComparisons,
  });

  final List<WordComparison> wordComparisons;

  @override
  Widget build(BuildContext context) {
    if (wordComparisons.isEmpty) {
      return Text(
        '(Không có nội dung)',
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.mutedForeground,
        ),
      );
    }

    final spans = <InlineSpan>[];
    for (var i = 0; i < wordComparisons.length; i++) {
      final comparison = wordComparisons[i];
      if (i > 0) {
        spans.add(const TextSpan(text: ' '));
      }
      spans.add(
        TextSpan(
          text: comparison.originalWord,
          style: AppTypography.bodyLarge.copyWith(
            color: comparison.isCorrect
                ? AppColors.success
                : AppColors.destructive,
            fontWeight: comparison.isCorrect
                ? FontWeight.w400
                : FontWeight.w700,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
