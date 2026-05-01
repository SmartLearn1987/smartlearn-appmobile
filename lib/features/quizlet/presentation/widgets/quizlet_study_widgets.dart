import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/quizlet_term_entity.dart';

enum StudyMode { flashcard, front, back, practice }

class StudyModeTabs extends StatelessWidget {
  const StudyModeTabs({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final StudyMode value;
  final ValueChanged<StudyMode> onChanged;

  static const _tabs = [
    (label: 'Flashcard', mode: StudyMode.flashcard),
    (label: 'Kiểm tra\nmặt trước', mode: StudyMode.front),
    (label: 'Kiểm tra\nmặt sau', mode: StudyMode.back),
    (label: 'Luyện tập', mode: StudyMode.practice),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellW = constraints.maxWidth / 2;
          const cellH = 56.0;
          final activeIndex = _tabs.indexWhere((t) => t.mode == value);
          final col = activeIndex % 2;
          final row = activeIndex ~/ 2;

          return SizedBox(
            height: cellH * 2,
            child: Stack(
              children: [
                // ── Animated pill ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  left: col * cellW + AppSpacing.xs,
                  top: row * cellH + AppSpacing.xs,
                  width: cellW - AppSpacing.sm,
                  height: cellH - AppSpacing.sm,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppBorders.borderRadiusSm,
                    ),
                  ),
                ),
                // ── Labels ──
                Wrap(
                  children: List.generate(_tabs.length, (i) {
                    final selected = _tabs[i].mode == value;
                    return GestureDetector(
                      onTap: () => onChanged(_tabs[i].mode),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: cellW,
                        height: cellH,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primaryForeground
                                  : AppColors.mutedForeground,
                            ),
                            child: Text(
                              _tabs[i].label,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SingleFaceStudyCard extends StatelessWidget {
  const SingleFaceStudyCard({
    required this.text,
    required this.textColor,
    super.key,
  });

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(
              color: textColor,
              fontSize: adaptiveStudyFontSize(text, context),
            ),
          ),
        ),
      ),
    );
  }
}

class PracticeStudyCard extends StatelessWidget {
  const PracticeStudyCard({required this.term, super.key});

  final QuizletTermEntity term;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.md),
                  topRight: Radius.circular(AppSpacing.md),
                ),
              ),
              child: Center(
                child: Text(
                  term.term,
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.destructive,
                    fontSize: adaptiveStudyFontSize(term.term, context),
                  ),
                ),
              ),
            ),
          ),
          Container(height: 1, color: AppColors.border),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.md),
                  bottomRight: Radius.circular(AppSpacing.md),
                ),
              ),
              child: Center(
                child: Text(
                  term.definition,
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: Colors.blue.shade700,
                    fontSize: adaptiveStudyFontSize(term.definition, context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double adaptiveStudyFontSize(String text, BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  var size = width < 380 ? 26.0 : 32.0;
  final length = text.trim().length;
  if (length > 120) {
    size = width < 380 ? 16 : 18;
  } else if (length > 70) {
    size = width < 380 ? 18 : 22;
  } else if (length > 40) {
    size = width < 380 ? 20 : 26;
  }
  return size;
}
