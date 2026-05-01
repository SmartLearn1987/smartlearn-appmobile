import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/theme.dart';

/// Reusable dropdown field matching AppTextField style.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hintText,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hintText;
  final bool enabled;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          autovalidateMode: autovalidateMode,
          isExpanded: true,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.mutedForeground,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            filled: true,
            fillColor: enabled ? AppColors.card : AppColors.muted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
            isDense: true,
            border: _border(AppColors.input),
            enabledBorder: _border(AppColors.input),
            focusedBorder: _border(
              AppColors.primary,
              width: AppBorders.widthMedium,
            ),
            errorBorder: _border(AppColors.destructive),
            focusedErrorBorder: _border(
              AppColors.destructive,
              width: AppBorders.widthMedium,
            ),
            disabledBorder: _border(AppColors.muted),
          ),
          dropdownColor: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          menuMaxHeight: 320,
        ),
      ],
    );
  }

  OutlineInputBorder _border(
    Color color, {
    double width = AppBorders.widthThin,
  }) => OutlineInputBorder(
    borderRadius: AppBorders.borderRadiusSm,
    borderSide: BorderSide(color: color, width: width),
  );
}
