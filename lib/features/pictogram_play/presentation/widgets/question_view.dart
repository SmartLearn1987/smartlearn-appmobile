import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';

/// Displays a single pictogram question with image, answer input,
/// action buttons, and feedback for correct/incorrect answers.
class QuestionView extends StatefulWidget {
  const QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onSubmit,
    required this.onSkip,
    required this.onNext,
    this.lastAnswerResult,
    super.key,
  });

  final PictogramEntity question;
  final int currentIndex;
  final int totalQuestions;
  final AnswerResult? lastAnswerResult;
  final ValueChanged<String> onSubmit;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  final _answerController = TextEditingController();

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _answerController.clear();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _answerController.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = widget.lastAnswerResult != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question progress
          Text(
            formatProgress(widget.currentIndex, widget.totalQuestions),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Question image
          ClipRRect(
            borderRadius: AppBorders.borderRadiusMd,
            child: Image.network(
              widget.question.imageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: AppBorders.borderRadiusMd,
                ),
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Answer feedback
          if (hasResult) _buildFeedback(),

          // Answer input
          if (!hasResult) ...[
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.smMd,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadiusSm,
                  borderSide: const BorderSide(
                    color: AppColors.input,
                    width: AppBorders.widthThin,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadiusSm,
                  borderSide: const BorderSide(
                    color: AppColors.input,
                    width: AppBorders.widthThin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadiusSm,
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: AppBorders.widthMedium,
                  ),
                ),
              ),
              style: AppTypography.bodyLarge,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Submit and Skip buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mutedForeground,
                      side: const BorderSide(
                        color: AppColors.border,
                        width: AppBorders.widthThin,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.smMd,
                      ),
                      shape: AppBorders.shapeSm,
                    ),
                    child: Text(
                      'Bỏ qua',
                      style: AppTypography.buttonLarge,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.smMd,
                      ),
                      shape: AppBorders.shapeSm,
                      elevation: 0,
                    ),
                    child: Text(
                      'Trả lời',
                      style: AppTypography.buttonLarge,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Next button (shown after answering)
          if (hasResult) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.smMd,
                ),
                shape: AppBorders.shapeSm,
                elevation: 0,
              ),
              child: Text(
                'Tiếp tục',
                style: AppTypography.buttonLarge,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    final isCorrect = widget.lastAnswerResult == AnswerResult.correct;
    final feedbackColor = isCorrect ? AppColors.success : AppColors.destructive;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: feedbackColor,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: feedbackColor,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isCorrect ? 'Chính xác!' : 'Sai rồi!',
            style: AppTypography.labelLarge.copyWith(color: feedbackColor),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Đáp án: ${widget.question.answer}',
              style: AppTypography.bodyMedium.copyWith(color: feedbackColor),
            ),
          ],
        ],
      ),
    );
  }
}
