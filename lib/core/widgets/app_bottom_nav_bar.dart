import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: LucideIcons.home, label: 'Trang chủ'),
    (icon: LucideIcons.bookOpen, label: 'Sổ tay môn học'),
    (icon: LucideIcons.calendarClock, label: 'Thời gian biểu'),
    (icon: LucideIcons.layers, label: 'Flashcards'),
    (icon: LucideIcons.clipboardList, label: 'Trắc nghiệm'),
    (icon: LucideIcons.user, label: 'Hồ sơ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.smMd,
        AppSpacing.mdLg,
        AppSpacing.mdLg,
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(36)),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: AppBorders.borderRadiusFull,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.primaryForeground
                            : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
