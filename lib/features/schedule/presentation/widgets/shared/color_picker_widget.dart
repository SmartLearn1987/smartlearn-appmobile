import 'package:flutter/material.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({
    required this.colors,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(colors.length, (index) {
        final color = colors[index];
        final isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onChanged(index),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: AppColors.primary,
                      width: AppBorders.widthThick,
                    )
                  : null,
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppColors.card,
                      size: 16,
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
