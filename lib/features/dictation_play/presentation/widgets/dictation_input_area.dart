import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Input area for the dictation game where users type what they heard.
///
/// Displays a multiline [TextField], a word count indicator,
/// and a submit button that is disabled when the input is empty.
class DictationInputArea extends StatelessWidget {
  const DictationInputArea({
    required this.userInput,
    required this.wordCount,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  /// The current text the user has typed.
  final String userInput;

  /// Number of words the user has typed so far.
  final int wordCount;

  /// Called whenever the user changes the text in the input field.
  final ValueChanged<String> onChanged;

  /// Called when the user taps the submit button.
  /// Null when submission is not allowed.
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitEnabled = userInput.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Multiline text field
        TextField(
          onChanged: onChanged,
          maxLines: 6,
          minLines: 4,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: 'Gõ lại nội dung bạn đã nghe...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Word count indicator
        Text(
          'Số từ: $wordCount',
          style: AppTypography.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitEnabled ? onSubmit : null,
            style: AppButtonStyles.primary,
            child: Text(
              'Nộp bài',
              style: AppTypography.buttonLarge,
            ),
          ),
        ),
      ],
    );
  }
}
