import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: LucideIcons.bookOpen, label: 'Sổ tay môn học'),
    (icon: LucideIcons.calendarClock, label: 'Thời gian biểu'),
    (icon: LucideIcons.home, label: 'Trang chủ'),
    (icon: LucideIcons.layers, label: 'Flashcards'),
    (icon: LucideIcons.clipboardList, label: 'Trắc nghiệm'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.mdLg,
          0,
          AppSpacing.mdLg,
          0,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: itemWidth * currentIndex,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppBorders.borderRadiusFull,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = currentIndex == index;
                      return Expanded(
                        child: InkWell(
                          onTap: () => onTap(index),
                          borderRadius: AppBorders.borderRadiusFull,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.95,
                                      end: 1,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                item.icon,
                                key: ValueKey('${item.label}-$isSelected'),
                                size: 18,
                                color: isSelected
                                    ? AppColors.primaryForeground
                                    : AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
