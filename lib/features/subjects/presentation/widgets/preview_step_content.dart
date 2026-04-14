import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/education_level.dart';
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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(state),
              const SizedBox(height: AppSpacing.md),
              _buildName(state),
              const SizedBox(height: AppSpacing.xs),
              _buildPublisher(state),
              const SizedBox(height: AppSpacing.smMd),
              _buildBadges(state),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRows(state),
              const SizedBox(height: AppSpacing.lg),
              _buildButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverImage(CurriculumFormState state) {
    return Center(
      child: ClipRRect(
        borderRadius: AppBorders.borderRadiusLg,
        child: state.imageFile != null
            ? Image.file(
                state.imageFile!,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              )
            : state.existingImageUrl != null
                ? Image.network(
                    state.existingImageUrl!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackIcon(),
                  )
                : _buildFallbackIcon(),
      ),
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

  Widget _buildName(CurriculumFormState state) {
    final name = state.name.trim().isEmpty ? 'Chưa đặt tên' : state.name;
    return Center(
      child: Text(
        name,
        style: AppTypography.h3.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPublisher(CurriculumFormState state) {
    final publisher = state.publisher.trim().isEmpty
        ? 'Chưa chọn NXB'
        : state.publisher;
    return Center(
      child: Text(
        publisher,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildBadges(CurriculumFormState state) {
    final level = EducationLevel.fromApiValue(state.educationLevel);
    final levelLabel = level?.displayLabel ?? 'Chưa phân loại';
    final gradeLabel =
        state.grade.trim().isEmpty ? 'Chưa chọn lớp' : 'Lớp ${state.grade}';
    final visibilityLabel = state.isPublic ? '🌍 Công khai' : '🔒 Cá nhân';

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        _badge(gradeLabel),
        _badge(levelLabel),
        _badge(visibilityLabel),
      ],
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildInfoRows(CurriculumFormState state) {
    return Column(
      children: [
        if (subjectName != null)
          _infoRow('Môn học', subjectName!),
        _infoRow('Số bài học dự kiến', '${state.lessonCount}'),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, CurriculumFormState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context
                .read<CurriculumFormBloc>()
                .add(const CurriculumFormStepChanged(step: 0)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mutedForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('← Quay lại sửa'),
          ),
        ),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () => context
                    .read<CurriculumFormBloc>()
                    .add(CurriculumFormSubmitted(subjectId: subjectId)),
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
                : const Text('Xác nhận & Lưu giáo trình'),
          ),
        ),
      ],
    );
  }
}
