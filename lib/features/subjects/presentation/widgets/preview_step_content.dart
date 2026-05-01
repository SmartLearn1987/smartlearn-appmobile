import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/constants/education_level.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../../../core/widgets/app_cached_image.dart';
import '../bloc/curriculum_form/curriculum_form_bloc.dart';

class PreviewStepContent extends StatelessWidget {
  const PreviewStepContent({
    required this.subjectId,
    this.subjectName,
    super.key,
  });

  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurriculumFormBloc, CurriculumFormState>(
      builder: (context, state) {
        final name = state.name.trim().isEmpty ? 'Chưa đặt tên' : state.name;
        final publisher = state.publisher.trim().isEmpty
            ? 'Chưa chọn NXB'
            : state.publisher;
        return SingleChildScrollView(
          child: Column(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.3),
                  borderRadius: AppBorders.borderRadiusLg,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppBorders.widthThin,
                  ),
                ),
                child: Column(
                  spacing: AppSpacing.md,
                  children: [
                    Row(
                      spacing: AppSpacing.md,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: AppBorders.borderRadiusLg,
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: AppBorders.borderRadiusLg,
                              border: Border.all(
                                color: AppColors.border,
                                width: AppBorders.widthThin,
                              ),
                            ),
                            child: state.imageFile != null
                                ? Image.file(
                                    state.imageFile!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  )
                                : state.existingImageUrl != null
                                ? AppCachedImage(
                                    imageUrl: state.existingImageUrl!,
                                    width: 96,
                                    height: 96,
                                    borderRadius: AppBorders.borderRadiusLg,
                                    errorWidget: _buildFallbackIcon(),
                                  )
                                : _buildFallbackIcon(),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: AppSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                publisher,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              _buildBadges(state),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      spacing: AppSpacing.md,
                      children: [
                        Expanded(
                          child: Column(
                            spacing: AppSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Môn học'.toUpperCase(),
                                style: AppTypography.bodyMedium.bold.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              Text(
                                subjectName ?? 'Chưa chọn môn học',
                                style: AppTypography.bodyMedium.bold.copyWith(
                                  color: AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: AppSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số bài học'.toUpperCase(),
                                style: AppTypography.bodyMedium.bold.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              Text(
                                '${state.lessonCount} bài',
                                style: AppTypography.bodyMedium.bold.copyWith(
                                  color: AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppBorders.borderRadiusLg,
      ),
      child: const Icon(
        LucideIcons.bookOpen,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }

  Widget _buildBadges(CurriculumFormState state) {
    final level = EducationLevel.fromApiValue(state.educationLevel);
    final levelLabel = level?.label ?? 'Chưa chọn cấp độ';
    final gradeLabel = state.grade.trim().isEmpty
        ? 'Lớp ?'
        : 'Lớp ${state.grade}';
    final visibilityLabel = state.isPublic ? 'Công khai' : 'Riêng tư';

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        _badge(gradeLabel, AppColors.primary),
        _badge(levelLabel, AppColors.primary),
        _badge(visibilityLabel, AppColors.mutedForeground),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Text(
        text,
        style: AppTypography.caption.bold.copyWith(color: color),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, CurriculumFormState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.read<CurriculumFormBloc>().add(
              const CurriculumFormStepChanged(step: 0),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Row(
              spacing: AppSpacing.xs,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.arrowLeft,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                Flexible(
                  child: Text(
                    'Quay lại',
                    style: AppTypography.buttonMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(
          child: ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<CurriculumFormBloc>().add(
                    CurriculumFormSubmitted(subjectId: subjectId),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryForeground,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.xs,
                    children: [
                      const Icon(
                        LucideIcons.upload,
                        size: 16,
                        color: AppColors.primaryForeground,
                      ),
                      Flexible(
                        child: Text(
                          'Xác nhận & Lưu',
                          style: AppTypography.buttonMedium.copyWith(
                            color: AppColors.primaryForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
