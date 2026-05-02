import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Section label kiểu uppercase + letter spacing dùng chung trong feature
/// Chép chính tả (TIÊU ĐỀ, NỘI DUNG, ...).
class DictationSectionLabel extends StatelessWidget {
  const DictationSectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.mutedForeground,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Container kiểu "muted card" dùng chung cho phần TIÊU ĐỀ / NỘI DUNG / vùng nhập.
class DictationCard extends StatelessWidget {
  const DictationCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.muted.withValues(alpha: 0.4),
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
