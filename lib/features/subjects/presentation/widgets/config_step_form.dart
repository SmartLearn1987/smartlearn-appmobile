import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/constants/education_level.dart';
import 'package:smart_learn/core/constants/visibility.dart';
import 'package:smart_learn/core/validators/form_validators.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/photo_gallery/show_photo_gallery.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/curriculum_form/curriculum_form_bloc.dart';

class ConfigStepForm extends StatefulWidget {
  const ConfigStepForm({this.onCancel, super.key});

  final VoidCallback? onCancel;

  @override
  State<ConfigStepForm> createState() => _ConfigStepFormState();
}

class _ConfigStepFormState extends State<ConfigStepForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurriculumFormBloc, CurriculumFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.errorMessage != null) ...[
                  _buildErrorBanner(state.errorMessage!),
                  const SizedBox(height: AppSpacing.md),
                ],
                _buildVisibilityDropdown(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildEducationLevelDropdown(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildNameField(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildGradeField(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildPublisherField(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildLessonCountField(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildImagePicker(context, state),
                const SizedBox(height: AppSpacing.lg),
                _buildButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.destructive.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(color: AppColors.destructive),
      ),
    );
  }

  Widget _buildVisibilityDropdown(
    BuildContext context,
    CurriculumFormState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chế độ hiển thị',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<bool>(
          key: ValueKey('visibility_${state.isPublic}'),
          initialValue: state.isPublic,
          decoration: _dropdownDecoration(),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
          items: [
            DropdownMenuItem(
              value: VisibilityMode.private.value,
              child: Text(VisibilityMode.private.displayLabel),
            ),
            DropdownMenuItem(
              value: VisibilityMode.public.value,
              child: Text(VisibilityMode.public.displayLabel),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<CurriculumFormBloc>().add(
                CurriculumFormFieldChanged(field: 'isPublic', value: value),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildEducationLevelDropdown(
    BuildContext context,
    CurriculumFormState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cấp độ',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          key: ValueKey('level_${state.educationLevel}'),
          initialValue: state.educationLevel.isEmpty
              ? null
              : state.educationLevel,
          decoration: _dropdownDecoration(),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
          hint: Text(
            'Chọn cấp độ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          items: EducationLevel.values.map((level) {
            return DropdownMenuItem(
              value: level.toApiValue(),
              child: Text(level.displayLabel),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<CurriculumFormBloc>().add(
                CurriculumFormFieldChanged(
                  field: 'educationLevel',
                  value: value,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context, CurriculumFormState state) {
    return AppTextField(
      label: 'Tên giáo trình *',
      hintText: 'VD: Tiếng Việt 4 - Kết nối tri thức',
      controller: TextEditingController(text: state.name)
        ..selection = TextSelection.collapsed(offset: state.name.length),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => FormValidators.required(value, 'Tên giáo trình'),
      onChanged: (value) => context.read<CurriculumFormBloc>().add(
        CurriculumFormFieldChanged(field: 'name', value: value),
      ),
    );
  }

  Widget _buildGradeField(BuildContext context, CurriculumFormState state) {
    return AppTextField(
      label: 'Lớp',
      hintText: 'VD: 4',
      controller: TextEditingController(text: state.grade)
        ..selection = TextSelection.collapsed(offset: state.grade.length),
      onChanged: (value) => context.read<CurriculumFormBloc>().add(
        CurriculumFormFieldChanged(field: 'grade', value: value),
      ),
    );
  }

  Widget _buildPublisherField(BuildContext context, CurriculumFormState state) {
    return AppTextField(
      label: 'Nhà xuất bản',
      hintText: 'VD: NXB Giáo dục',
      controller: TextEditingController(text: state.publisher)
        ..selection = TextSelection.collapsed(offset: state.publisher.length),
      onChanged: (value) => context.read<CurriculumFormBloc>().add(
        CurriculumFormFieldChanged(field: 'publisher', value: value),
      ),
    );
  }

  Widget _buildLessonCountField(
    BuildContext context,
    CurriculumFormState state,
  ) {
    return AppTextField(
      label: 'Số lượng bài học dự kiến',
      hintText: '1',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: TextEditingController(text: '${state.lessonCount}')
        ..selection = TextSelection.collapsed(
          offset: '${state.lessonCount}'.length,
        ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final parsed = int.tryParse(value);
          if (parsed == null || parsed < 1) {
            return 'Số bài học phải lớn hơn 0';
          }
        }
        return null;
      },
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed >= 1) {
          context.read<CurriculumFormBloc>().add(
            CurriculumFormFieldChanged(field: 'lessonCount', value: parsed),
          );
        }
      },
    );
  }

  Widget _buildImagePicker(BuildContext context, CurriculumFormState state) {
    final hasImage = state.imageFile != null || state.existingImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ảnh bìa',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (hasImage)
          _buildImagePreview(context, state)
        else
          _buildImagePlaceholder(context),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.imagePlus,
              size: 32,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tải ảnh bìa (JPG, PNG, WEBP)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, CurriculumFormState state) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final items = <PhotoGalleryItem>[];
            if (state.imageFile != null) {
              items.add(PhotoGalleryLocalFile(state.imageFile!));
            } else if (state.existingImageUrl != null &&
                state.existingImageUrl!.trim().isNotEmpty) {
              items.add(PhotoGalleryNetworkUrl(state.existingImageUrl!));
            }
            if (items.isNotEmpty && context.mounted) {
              showPhotoGallery(context, items: items);
            }
          },
          child: ClipRRect(
            borderRadius: AppBorders.borderRadiusSm,
            child: state.imageFile != null
                ? Image.file(
                    state.imageFile!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  )
                : AppCachedImage(
                    imageUrl: state.existingImageUrl!,
                    width: 96,
                    height: 96,
                    borderRadius: AppBorders.borderRadiusSm,
                    errorWidget: _buildFallbackIcon(),
                  ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => context.read<CurriculumFormBloc>().add(
              const CurriculumFormImageRemoved(),
            ),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.destructive,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.x,
                size: 14,
                color: AppColors.primaryForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppBorders.borderRadiusSm,
      ),
      child: const Icon(
        LucideIcons.bookOpen,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      context.read<CurriculumFormBloc>().add(
        CurriculumFormImageSelected(file: File(picked.path)),
      );
    }
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                widget.onCancel ?? () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.destructive,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(color: AppColors.destructive),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<CurriculumFormBloc>().add(
                  const CurriculumFormStepChanged(step: 1),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
            ),
            child: const Text('Tiếp tục: Xem trước →'),
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
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
          width: AppBorders.widthMedium,
        ),
      ),
    );
  }
}
