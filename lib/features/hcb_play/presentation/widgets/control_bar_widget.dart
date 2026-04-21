import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Bottom control bar for the flashcard game.
///
/// Provides previous, auto-play toggle, shuffle, and next buttons.
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
          // Previous button
          _ControlButton(
            icon: LucideIcons.chevronLeft,
            onPressed: _isFirst ? null : onPrevious,
            semanticLabel: 'Câu trước',
          ),
          // Auto-play toggle
          _AutoPlayButton(
            isActive: isAutoPlaying,
            onPressed: onToggleAutoPlay,
          ),
          // Shuffle button
          _ControlButton(
            icon: LucideIcons.shuffle,
            onPressed: onShuffle,
            semanticLabel: 'Xáo trộn',
          ),
          // Next button
          _ControlButton(
            icon: LucideIcons.chevronRight,
            onPressed: _isLast ? null : onNext,
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
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Material(
        color: _isDisabled ? AppColors.muted : AppColors.card,
        borderRadius: AppBorders.borderRadiusFull,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppBorders.borderRadiusFull,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDisabled ? AppColors.muted : AppColors.border,
                width: AppBorders.widthThin,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: _isDisabled
                  ? AppColors.mutedForeground
                  : AppColors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Auto-Play Button ────────────────────────────────────────────────────

class _AutoPlayButton extends StatelessWidget {
  const _AutoPlayButton({
    required this.isActive,
    required this.onPressed,
  });

  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isActive ? 'Dừng tự động phát' : 'Tự động phát',
      child: Material(
        color: isActive ? AppColors.primary : AppColors.card,
        borderRadius: AppBorders.borderRadiusFull,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppBorders.borderRadiusFull,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: AppBorders.widthThin,
              ),
            ),
            child: Icon(
              isActive ? LucideIcons.pause : LucideIcons.play,
              size: 28,
              color: isActive
                  ? AppColors.primaryForeground
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
