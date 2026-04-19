import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
        final isChecked = currentStatus == AnswerStatus.checkedCorrect ||
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
            // ─── Header ───
            _buildHeader(context, state),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Question Grid ───
            _buildQuestionGrid(context, state),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Progress Bar ───
            _buildProgressBar(progress, checkedCount, total),
            const SizedBox(height: AppSpacing.smMd),

            // ─── Scrollable content ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ─── Question Card ───
                    _buildQuestionCard(state.currentIndex, question.question),
                    const SizedBox(height: AppSpacing.md),

                    // ─── Hint Card ───
                    if (state.isHintVisible)
                      _buildHintCard(question.hint),

                    // ─── Feedback ───
                    if (state.lastCheckResult != null)
                      _buildFeedback(state.lastCheckResult!),

                    if (!isChecked) ...[
                      const SizedBox(height: AppSpacing.md),
                      // ─── Answer Input ───
                      _buildAnswerInput(context),
                    ],

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // ─── Bottom Nav ───
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
    final progressStr = formatProgress(state.currentIndex, state.questions.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  Text(
                    'Vua Tiếng Việt',
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
          // Kết thúc button
          SizedBox(
            width: 140,
            height: 36,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<VTVPlayBloc>().add(const EndGame()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
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

  Widget _buildQuestionGrid(BuildContext context, VTVPlayInProgress state) {
    final total = state.questions.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border:
            Border.all(color: AppColors.border, width: AppBorders.widthThin),
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
              children: List.generate(total, (i) {
                final isCurrent = i == state.currentIndex;
                final status =
                    state.answerStatuses[i] ?? AnswerStatus.unanswered;

                Color bgColor;
                Color textColor;

                if (isCurrent) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
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

                return Padding(
                  padding: EdgeInsets.only(
                    right: i < total - 1 ? AppSpacing.xs : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => context
                        .read<VTVPlayBloc>()
                        .add(GoToQuestion(index: i)),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Progress Bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProgressBar(double progress, int checked, int total) {
    final percent = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$checked/$total ($percent%)',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppBorders.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.muted,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
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
          Text(
            questionText,
            style: AppTypography.h3.copyWith(
              color: AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hint Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHintCard(String hint) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hint,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
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
            style: AppTypography.h4.copyWith(
              color: AppColors.foreground,
            ),
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              context
                  .read<VTVPlayBloc>()
                  .add(UpdateAnswer(answer: value));
            },
            onSubmitted: (_) => _handleCheck(context),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleCheck(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: AppBorders.shapeSm,
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Kiểm tra'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () =>
                    context.read<VTVPlayBloc>().add(const ToggleHint()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: AppBorders.shapeSm,
                  minimumSize: const Size(0, 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
                child: const Text('Gợi ý'),
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
                      .read<VTVPlayBloc>()
                      .add(GoToQuestion(index: i)),
                  child: Container(
                    width: isCurrent ? 12 : 8,
                    height: isCurrent ? 12 : 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.muted,
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
                        .read<VTVPlayBloc>()
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
                        .read<VTVPlayBloc>()
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
