import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Bottom control bar for the flashcard game.
///
/// Bốn nút bo góc vuông (squircle) đặt cạnh nhau:
///   - Trở lại
///   - Phát/Tạm dừng tự động
///   - Xáo trộn
///   - Tiếp theo
class ControlBarWidget extends StatelessWidget {
  const ControlBarWidget({
    required this.currentIndex,
    required this.totalCount,
    required this.isAutoPlaying,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleAutoPlay,
    required this.onShuffle,
    super.key,
  });

  final int currentIndex;
  final int totalCount;
  final bool isAutoPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleAutoPlay;
  final VoidCallback onShuffle;

  bool get _isFirst => currentIndex == 0;
  bool get _isLast => currentIndex == totalCount - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.smMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: LucideIcons.chevronLeft,
            onPressed: _isFirst ? null : onPrevious,
            backgroundColor: AppColors.card,
            borderColor: AppColors.border,
            foregroundColor: AppColors.foreground,
            semanticLabel: 'Câu trước',
          ),
          _ControlButton(
            icon: isAutoPlaying ? LucideIcons.pause : LucideIcons.play,
            onPressed: onToggleAutoPlay,
            backgroundColor: AppColors.emerald100,
            borderColor: AppColors.emerald100,
            foregroundColor: AppColors.primary,
            semanticLabel: isAutoPlaying ? 'Tạm dừng' : 'Tự động phát',
          ),
          _ControlButton(
            icon: LucideIcons.shuffle,
            onPressed: onShuffle,
            backgroundColor: AppColors.amber50,
            borderColor: AppColors.amber50,
            foregroundColor: AppColors.secondary,
            semanticLabel: 'Xáo trộn',
          ),
          _ControlButton(
            icon: LucideIcons.chevronRight,
            onPressed: _isLast ? null : onNext,
            backgroundColor: AppColors.card,
            borderColor: AppColors.border,
            foregroundColor: AppColors.foreground,
            semanticLabel: 'Câu sau',
          ),
        ],
      ),
    );
  }
}

// ─── Control Button ──────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final String semanticLabel;

  static const double _size = 56;
  static const BorderRadius _radius = AppBorders.borderRadiusXl;

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final bg = _isDisabled ? AppColors.muted : backgroundColor;
    final border = _isDisabled ? AppColors.muted : borderColor;
    final fg = _isDisabled ? AppColors.mutedForeground : foregroundColor;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: bg,
        borderRadius: _radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: _radius,
          child: Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: _radius,
              border: Border.all(color: border, width: AppBorders.widthThin),
            ),
            child: Icon(icon, size: 26, color: fg),
          ),
        ),
      ),
    );
  }
}
