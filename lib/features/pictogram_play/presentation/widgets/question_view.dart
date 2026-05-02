import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../../../core/widgets/app_cached_image.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';
import '../controllers/game_session_controller.dart';

class QuestionView extends StatefulWidget {
  const QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.answeredQuestions,
    required this.session,
    required this.onGoTo,
    required this.onPrevious,
    required this.onNext,
    required this.onEndGame,
    super.key,
  });

  final PictogramEntity question;
  final int currentIndex;
  final int totalQuestions;
  final int remainingSeconds;
  final Map<int, AnswerResult> answeredQuestions;
  final GameSessionController session;
  final ValueChanged<int> onGoTo;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onEndGame;

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  /// Mỗi từ trong câu hiện tại có 1 [FocusNode] để auto-advance giữa các Pinput.
  List<FocusNode> _wordFocusNodes = const [];

  @override
  void initState() {
    super.initState();
    _rebuildFocusNodes();
    // Sau khi build xong, focus ô từ đầu tiên còn trống → mở bàn phím luôn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusFirstIncompleteWord();
    });
  }

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _rebuildFocusNodes();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusFirstIncompleteWord();
      });
    }
  }

  @override
  void dispose() {
    for (final n in _wordFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _rebuildFocusNodes() {
    for (final n in _wordFocusNodes) {
      n.dispose();
    }
    final words = widget.session.wordsFor(widget.currentIndex);
    _wordFocusNodes = List.generate(words.length, (_) => FocusNode());
  }

  void _focusFirstIncompleteWord() {
    final words = widget.session.wordsFor(widget.currentIndex);
    final controllers = widget.session.wordControllersFor(widget.currentIndex);
    for (var i = 0; i < words.length; i++) {
      if (controllers[i].text.length < words[i].length) {
        _wordFocusNodes[i].requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(timeStr),
                const SizedBox(height: AppSpacing.smMd),
                _buildQuestionNavigator(),
                const SizedBox(height: AppSpacing.smMd),
                _buildImageCard(),
                const SizedBox(height: AppSpacing.md),
                _buildPinputGroups(),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        _buildBottomNav(),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(String timeStr) {
    final isLow = widget.remainingSeconds <= 30;
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
              onPressed: widget.onEndGame,
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

  // ── Question navigator ───────────────────────────────────────────────────────

  Widget _buildQuestionNavigator() {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.totalQuestions, (i) {
                final isCurrent = i == widget.currentIndex;
                final result = widget.answeredQuestions[i];
                Color bgColor;
                Color textColor;
                if (isCurrent) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                } else if (result != null) {
                  bgColor = result == AnswerResult.correct
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.destructive.withValues(alpha: 0.15);
                  textColor = result == AnswerResult.correct
                      ? AppColors.success
                      : AppColors.destructive;
                } else {
                  bgColor = AppColors.muted;
                  textColor = AppColors.foreground;
                }
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < widget.totalQuestions - 1 ? AppSpacing.xs : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => widget.onGoTo(i),
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
          ),
        ],
      ),
    );
  }

  // ── Image card ───────────────────────────────────────────────────────────────

  Widget _buildImageCard() {
    return Container(
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
              'CÂU ĐỐ ${widget.currentIndex + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCachedImage(
            imageUrl: widget.question.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: AppBorders.borderRadiusMd,
          ),
        ],
      ),
    );
  }

  // ── Pinput groups (mỗi từ = 1 Pinput) ───────────────────────────────────────

  Widget _buildPinputGroups() {
    final words = widget.session.wordsFor(widget.currentIndex);
    final controllers = widget.session.wordControllersFor(widget.currentIndex);

    final defaultTheme = PinTheme(
      width: 44,
      height: 48,
      textStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        color: AppColors.primary.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final submittedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.md,
        children: List.generate(words.length, (wordIndex) {
          return Pinput(
            length: words[wordIndex].length,
            controller: controllers[wordIndex],
            focusNode: _wordFocusNodes[wordIndex],
            defaultPinTheme: defaultTheme,
            focusedPinTheme: focusedTheme,
            submittedPinTheme: submittedTheme,
            separatorBuilder: (_) => const SizedBox(width: AppSpacing.xs),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            enableSuggestions: false,
            inputFormatters: [_UpperCaseTextFormatter()],
            showCursor: true,
            cursor: Container(
              width: 1.5,
              height: 22,
              color: AppColors.primary,
            ),
            onCompleted: (_) {
              final next = wordIndex + 1;
              if (next < _wordFocusNodes.length) {
                _wordFocusNodes[next].requestFocus();
              } else {
                _wordFocusNodes[wordIndex].unfocus();
              }
            },
            onChanged: (_) => setState(() {}),
          );
        }),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final isFirst = widget.currentIndex == 0;
    final isLast = widget.currentIndex == widget.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.smMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: isFirst ? null : widget.onPrevious,
            icon: const Icon(LucideIcons.chevronLeft, size: 20),
            label: const Text('CÂU TRƯỚC'),
            style: TextButton.styleFrom(
              foregroundColor: isFirst
                  ? AppColors.mutedForeground
                  : AppColors.primary,
            ),
          ),
          TextButton.icon(
            onPressed: isLast ? null : widget.onNext,
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

/// Buộc mọi ký tự nhập vào Pinput thành chữ hoa.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
