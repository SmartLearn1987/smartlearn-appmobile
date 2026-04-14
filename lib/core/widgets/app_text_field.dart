import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

/// Reusable text field matching Smart Learn design system.
///
/// Supports optional [label], [hintText], [prefixIcon], [suffixIcon],
/// [obscureText], [keyboardType], [validator], [onChanged], etc.
///
/// Design spec: height 44px, radius 12px, border #E3DFD8,
/// Quicksand 14px, icon size 18px, icon color #9CA3AF.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? helperText;

  /// Icon data for prefix — rendered as 18px icon in muted color.
  final IconData? prefixIcon;

  /// Icon data for suffix — rendered as 18px icon in muted color.
  final IconData? suffixIcon;

  /// Custom widget for prefix (overrides [prefixIcon]).
  final Widget? prefix;

  /// Custom widget for suffix (overrides [suffixIcon]).
  final Widget? suffix;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
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
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          textCapitalization: textCapitalization,
          autovalidateMode: autovalidateMode,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            errorText: errorText,
            helperText: helperText,
            helperStyle: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
            prefixIcon: _buildPrefix(),
            suffixIcon: _buildSuffix(),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 44,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 44,
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
            focusedBorder: _border(AppColors.primary, width: AppBorders.widthMedium),
            errorBorder: _border(AppColors.destructive),
            focusedErrorBorder: _border(AppColors.destructive, width: AppBorders.widthMedium),
            disabledBorder: _border(AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefix() {
    if (prefix != null) return Padding(padding: const EdgeInsets.only(left: AppSpacing.md), child: prefix);
    if (prefixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Icon(prefixIcon, size: 18, color: AppColors.mutedForeground),
      );
    }
    return null;
  }

  Widget? _buildSuffix() {
    if (suffix != null) return Padding(padding: const EdgeInsets.only(right: AppSpacing.md), child: suffix);
    if (suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(suffixIcon, size: 18, color: AppColors.mutedForeground),
      );
    }
    return null;
  }

  OutlineInputBorder _border(Color color, {double width = AppBorders.widthThin}) =>
      OutlineInputBorder(
        borderRadius: AppBorders.borderRadiusSm,
        borderSide: BorderSide(color: color, width: width),
      );
}
