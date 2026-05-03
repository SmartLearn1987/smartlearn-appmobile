import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';

import '../../../../core/theme/theme.dart';

class CardFormWidget extends StatelessWidget {
  final int index;
  final CardFormData data;
  final bool canDelete;
  final ValueChanged<String> onTermChanged;
  final ValueChanged<String> onDefinitionChanged;
  final VoidCallback onDelete;

  const CardFormWidget({
    super.key,
    required this.index,
    required this.data,
    required this.canDelete,
    required this.onTermChanged,
    required this.onDefinitionChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    'Thẻ ${index + 1}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    color: AppColors.destructive,
                    padding: EdgeInsets.zero,
                    splashRadius: 16,
                    tooltip: 'Xóa thẻ',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: Key('card_term_$index'),
              initialValue: data.term,
              onChanged: onTermChanged,
              decoration: InputDecoration(
                hintText: 'Mặt trước (thuật ngữ)',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.smMd,
                ),
                isDense: true,
                border: _inputBorder(AppColors.input),
                enabledBorder: _inputBorder(AppColors.input),
                focusedBorder: _inputBorder(
                  AppColors.primary,
                  width: AppBorders.widthMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: Key('card_definition_$index'),
              initialValue: data.definition,
              onChanged: onDefinitionChanged,
              decoration: InputDecoration(
                hintText: 'Mặt sau (định nghĩa)',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.smMd,
                ),
                isDense: true,
                border: _inputBorder(AppColors.input),
                enabledBorder: _inputBorder(AppColors.input),
                focusedBorder: _inputBorder(
                  AppColors.primary,
                  width: AppBorders.widthMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(
    Color color, {
    double width = AppBorders.widthThin,
  }) {
    return OutlineInputBorder(
      borderRadius: AppBorders.borderRadiusSm,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
