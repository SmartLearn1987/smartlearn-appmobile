import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';

class QuestionView extends StatefulWidget {
  const QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.answeredQuestions,
    required this.onSubmit,
    required this.onGoTo,
    required this.onPrevious,
    required this.onNext,
    required this.onEndGame,
    this.lastAnswerResult,
    super.key,
  });

  final PictogramEntity question;
  final int currentIndex;
  final int totalQuestions;
  final int remainingSeconds;
  final Map<int, AnswerResult> answeredQuestions;
  final AnswerResult? lastAnswerResult;
  final ValueChanged<String> onSubmit;
  final ValueChanged<int> onGoTo;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onEndGame;

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  late List<String?> _letterSlots;
  int _activeSlot = 0;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSlots();
  }

  @override
  void didUpdateWidget(covariant QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _initSlots();
      _answerController.clear();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _initSlots() {
    final answer = widget.question.answer.trim();
    _letterSlots = List.filled(answer.length, null);
    _activeSlot = 0;
  }

  void _onSlotTap(int index) {
    setState(() {
      _letterSlots[index] = null;
      _activeSlot = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = widget.lastAnswerResult != null;
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        // ─── Header ───
        _buildHeader(timeStr),
        const SizedBox(height: AppSpacing.smMd),

        // ─── Question Navigator ───
        _buildQuestionNavigator(),
        const SizedBox(height: AppSpacing.smMd),

        // ─── Image + Answer area ───
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildImageCard(hasResult),
                const SizedBox(height: AppSpacing.md),
                if (hasResult)
                  _buildFeedback()
                else ...[
                  _buildAnswerInput(),
                  const SizedBox(height: AppSpacing.md),
                  _buildLetterCircles(),
                ],
              ],
            ),
          ),
        ),

        // ─── Bottom Nav ───
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildHeader(String timeStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎮', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(
                    'Đuổi hình bắt chữ',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  Text(
                    'CÂU ${widget.currentIndex + 1} / ${widget.totalQuestions}',
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
                const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
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

  Widget _buildQuestionNavigator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: AppColors.border, width: AppBorders.widthThin),
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
                final isAnswered = result != null;

                Color bgColor;
                Color textColor;
                if (isCurrent) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                } else if (isAnswered) {
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

  Widget _buildImageCard(bool hasResult) {
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
            fit: BoxFit.contain,
            borderRadius: AppBorders.borderRadiusMd,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
                  borderSide: const BorderSide(color: AppColors.input),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadiusSm,
                  borderSide: const BorderSide(color: AppColors.input),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadiusSm,
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              style: AppTypography.bodyLarge,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
              onChanged: (value) {
                // Sync text input to letter slots for visual feedback
                setState(() {
                  final chars = value.split('');
                  for (var i = 0; i < _letterSlots.length; i++) {
                    _letterSlots[i] = i < chars.length ? chars[i] : null;
                  }
                  _activeSlot = chars.length < _letterSlots.length
                      ? chars.length
                      : _letterSlots.length;
                });
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: AppBorders.shapeSm,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: const Text('Trả lời'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final text = _answerController.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
    }
  }

  Widget _buildLetterCircles() {
    final answer = widget.question.answer.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: List.generate(answer.length, (i) {
          final letter = _letterSlots[i];
          final isActive = i == _activeSlot;

          return GestureDetector(
            onTap: letter != null ? () => _onSlotTap(i) : null,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: letter != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : letter != null
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: letter != null
                  ? Text(
                      letter.toUpperCase(),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeedback() {
    final isCorrect = widget.lastAnswerResult == AnswerResult.correct;
    final color = isCorrect ? AppColors.success : AppColors.destructive;

    return Container(
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
            isCorrect ? 'Chính xác!' : 'Sai rồi!',
            style: AppTypography.labelLarge.copyWith(color: color),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Đáp án: ${widget.question.answer}',
              style: AppTypography.bodyMedium.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Câu trước'),
            style: TextButton.styleFrom(
              foregroundColor:
                  isFirst ? AppColors.mutedForeground : AppColors.foreground,
            ),
          ),
          TextButton.icon(
            onPressed: isLast ? null : widget.onNext,
            icon: const Text(''),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Câu sau'),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            style: TextButton.styleFrom(
              foregroundColor:
                  isLast ? AppColors.mutedForeground : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
