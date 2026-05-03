import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../bloc/answer_status.dart';
import '../bloc/vtv_play_bloc.dart';

class VTVQuestionView extends StatefulWidget {
  const VTVQuestionView({super.key});

  @override
  State<VTVQuestionView> createState() => _VTVQuestionViewState();
}

class _VTVQuestionViewState extends State<VTVQuestionView> {
  final _answerController = TextEditingController();

  /// Track the question index so we can sync the controller on navigation.
  int _lastIndex = -1;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _syncController(VTVPlayInProgress state) {
    if (state.currentIndex != _lastIndex) {
      _lastIndex = state.currentIndex;
      final saved = state.userAnswers[state.currentIndex] ?? '';
      _answerController.text = saved;
      _answerController.selection = TextSelection.fromPosition(
        TextPosition(offset: saved.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTVPlayBloc, VTVPlayState>(
      builder: (context, state) {
        if (state is! VTVPlayInProgress) {
          return const SizedBox.shrink();
        }

        _syncController(state);

        final question = state.questions[state.currentIndex];
        final total = state.questions.length;
        final currentStatus =
            state.answerStatuses[state.currentIndex] ?? AnswerStatus.unanswered;
        final isChecked =
            currentStatus == AnswerStatus.checkedCorrect ||
            currentStatus == AnswerStatus.checkedIncorrect;
        final checkedCount = state.answerStatuses.values
            .where(
              (s) =>
                  s == AnswerStatus.checkedCorrect ||
                  s == AnswerStatus.checkedIncorrect,
            )
            .length;
        final progress = total > 0 ? checkedCount / total : 0.0;

        return Column(
          children: [
            // ─── Scrollable content ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildQuestionGrid(
                      context,
                      state,
                      progress: progress,
                      checkedCount: checkedCount,
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    _buildQuestionCard(state.currentIndex, question.question),
                    const SizedBox(height: AppSpacing.md),
                    if (state.isHintVisible)
                      _buildHintCard(context, question.hint),
                    if (state.lastCheckResult != null)
                      _buildFeedback(state.lastCheckResult!),
                    if (!isChecked) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildAnswerInput(context),
                    ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, VTVPlayInProgress state) {
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
              onPressed: () => context.read<VTVPlayBloc>().add(const EndGame()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  // ─────────────────────────────────────────────────────────────────────────
  // Question Grid
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildQuestionGrid(
    BuildContext context,
    VTVPlayInProgress state, {
    required double progress,
    required int checkedCount,
  }) {
    final total = state.questions.length;
    final percent = (progress * 100).toInt();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
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
            'DANH SÁCH CÂU HỎI',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'TIẾN TRÌNH CỦA BẠN',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // ─── Progress section ───
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
                '$percent%',
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
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(total, (i) {
              final isCurrent = i == state.currentIndex;
              final status = state.answerStatuses[i] ?? AnswerStatus.unanswered;

              Color bgColor;
              Color textColor;
              List<BoxShadow>? shadow;

              if (isCurrent) {
                bgColor = AppColors.primary;
                textColor = Colors.white;
                shadow = [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ];
              } else {
                switch (status) {
                  case AnswerStatus.checkedCorrect:
                    bgColor = AppColors.success.withValues(alpha: 0.15);
                    textColor = AppColors.success;
                  case AnswerStatus.checkedIncorrect:
                    bgColor = AppColors.destructive.withValues(alpha: 0.15);
                    textColor = AppColors.destructive;
                  case AnswerStatus.answered:
                    bgColor = AppColors.mutedForeground.withValues(alpha: 0.15);
                    textColor = AppColors.foreground;
                  case AnswerStatus.unanswered:
                    bgColor = AppColors.muted;
                    textColor = AppColors.mutedForeground;
                }
              }

              final isChecked =
                  status == AnswerStatus.checkedCorrect ||
                  status == AnswerStatus.checkedIncorrect;
              final isCorrect = status == AnswerStatus.checkedCorrect;

              return SizedBox(
                width: 40,
                height: 36,
                child: GestureDetector(
                  onTap: () =>
                      context.read<VTVPlayBloc>().add(GoToQuestion(index: i)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: AppBorders.borderRadiusSm,
                            boxShadow: shadow,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTypography.labelLarge.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      if (isChecked)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.destructive,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.card,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isCorrect ? LucideIcons.check : LucideIcons.x,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Question Card
  // ─────────────────────────────────────────────────────────────────────────

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
          SizedBox(
            width: double.infinity,
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

  // ─────────────────────────────────────────────────────────────────────────
  // Hint Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHintCard(BuildContext context, String hint) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.smMd,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.amber200,
                width: AppBorders.widthThin,
              ),
            ),
            child: Icon(
              LucideIcons.lightbulb,
              size: 20,
              color: AppColors.amber900,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                hint,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.amber900,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkResponse(
            onTap: () => context.read<VTVPlayBloc>().add(const ToggleHint()),
            radius: 18,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: Icon(LucideIcons.x, size: 18, color: AppColors.amber900),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Answer Input
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAnswerInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          TextField(
            controller: _answerController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
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
            style: AppTypography.h4.copyWith(color: AppColors.foreground),
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              context.read<VTVPlayBloc>().add(UpdateAnswer(answer: value));
            },
            onSubmitted: (_) => _handleCheck(context),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleCheck(context),
                  icon: const Icon(LucideIcons.check, size: 20),
                  label: const Text('Kiểm tra'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<VTVPlayBloc>().add(const ToggleHint()),
                style: AppButtonStyles.secondary,
                icon: const Icon(LucideIcons.info, size: 20),
                label: const Text('Gợi ý'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCheck(BuildContext context) {
    final text = _answerController.text.trim();
    if (text.isNotEmpty) {
      context.read<VTVPlayBloc>().add(CheckAnswer(answer: text));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Feedback
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFeedback(AnswerStatus result) {
    final isCorrect = result == AnswerStatus.checkedCorrect;
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
            isCorrect ? 'Chính xác!' : 'Sai rồi!',
            style: AppTypography.labelLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bottom Nav
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context, VTVPlayInProgress state) {
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
                      context.read<VTVPlayBloc>().add(const PreviousQuestion()),
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
                : () => context.read<VTVPlayBloc>().add(const NextQuestion()),
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
