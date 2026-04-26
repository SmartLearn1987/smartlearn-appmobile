import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (label: 'FlashCard', mode: StudyMode.flashcard),
      (label: 'Mặt trước', mode: StudyMode.front),
      (label: 'Mặt sau', mode: StudyMode.back),
      (label: 'Luyện tập', mode: StudyMode.practice),
    ];
    final activeIndex = tabs.indexWhere((tab) => tab.mode == value);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: tabWidth * activeIndex,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppBorders.borderRadiusSm,
                  ),
                ),
              ),
              Row(
                children: tabs.map((tab) {
                  final selected = tab.mode == value;
                  return Expanded(
                    child: InkWell(
                      borderRadius: AppBorders.borderRadiusSm,
                      onTap: () => onChanged(tab.mode),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                          horizontal: AppSpacing.xs,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primaryForeground
                                : AppColors.mutedForeground,
                          ),
                          child: Text(
                            tab.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
