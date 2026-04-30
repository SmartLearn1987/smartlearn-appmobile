import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/helpers/contants.dart';

// ─── Shell ────────────────────────────────────────────────────────────────────

/// Standard bottom-sheet container used by every game selection modal.
///
/// Provides the rounded top corners, background color, padding, drag handle,
/// and keyboard-inset spacing. Pass [child] for the modal body content.
class GameSelectionSheet extends StatelessWidget {
  const GameSelectionSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusXxl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.mdLg,
        AppSpacing.sm,
        AppSpacing.mdLg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          child,
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: AppBorders.borderRadiusFull,
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

/// Small bold label used above each chip group (e.g. "Cấp độ", "Số câu hỏi").
class GameSectionTitle extends StatelessWidget {
  const GameSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(color: AppColors.foreground),
    );
  }
}

// ─── Selection chip ───────────────────────────────────────────────────────────

/// Animated selection chip. When [isSelected] the chip fills with [activeColor]
/// and shows white text; otherwise it shows the default border style.
class GameSelectionChip extends StatelessWidget {
  const GameSelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.primary,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Fill + border color when selected. Defaults to [AppColors.accent].
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? activeColor : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}

// ─── Level chip (styled per difficulty) ──────────────────────────────────────

/// A chip that uses the [LevelConfig] colour palette from constants.
/// Selected state fills with the level's bg/border/text colours.
class LevelSelectionChip extends StatelessWidget {
  const LevelSelectionChip({
    required this.config,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final LevelConfig config;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? config.bg : AppColors.background,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: isSelected ? config.border : AppColors.border,
          ),
        ),
        child: Text(
          config.label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? config.text : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}

// ─── Level chip row ───────────────────────────────────────────────────────────

/// Renders the full row of level chips using [levels] from constants.
/// [selectedIndex] is the currently selected level index.
class LevelChipRow extends StatelessWidget {
  const LevelChipRow({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(levels.length, (i) {
        return LevelSelectionChip(
          config: levels[i],
          isSelected: selectedIndex == i,
          onTap: () => onSelected(i),
        );
      }),
    );
  }
}

// ─── Generic chip row ─────────────────────────────────────────────────────────

/// Renders a row of [GameSelectionChip]s from a list of string labels.
/// [selectedValue] is compared with each label to determine selection.
class ChipRow<T> extends StatelessWidget {
  const ChipRow({
    required this.items,
    required this.labelOf,
    required this.selectedValue,
    required this.onSelected,
    this.activeColor = AppColors.accent,
    super.key,
  });

  final List<T> items;
  final String Function(T) labelOf;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        return GameSelectionChip(
          label: labelOf(item),
          isSelected: selectedValue == item,
          activeColor: activeColor,
          onTap: () => onSelected(item),
        );
      }).toList(),
    );
  }
}

// ─── Play button ──────────────────────────────────────────────────────────────

/// Full-width "Chơi ngay" button with loading state.
/// Prefer [GameModalFooter] which also includes the cancel button.
class GamePlayButton extends StatelessWidget {
  const GamePlayButton({
    required this.onPressed,
    required this.isLoading,
    this.color = AppColors.accent,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: AppBorders.shapeMd,
          textStyle: AppTypography.buttonLarge,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Chơi ngay'),
      ),
    );
  }
}

// ─── Modal footer (cancel + play) ────────────────────────────────────────────

/// Standard two-button footer used by every game selection modal.
///
/// Left: outlined red "Hủy" button that pops the current route.
/// Right: filled "Chơi ngay" button with loading spinner.
class GameModalFooter extends StatelessWidget {
  const GameModalFooter({
    required this.onPlay,
    required this.isLoading,
    this.playColor = AppColors.accent,
    this.playEnabled = true,
    super.key,
  });

  final VoidCallback? onPlay;
  final bool isLoading;

  /// Background colour of the play button. Defaults to [AppColors.accent].
  final Color playColor;

  /// When false the play button is disabled regardless of [isLoading].
  final bool playEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.destructive,
              side: const BorderSide(color: AppColors.destructive),
              shape: AppBorders.shapeMd,
              textStyle: AppTypography.buttonLarge,
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Play button
        Expanded(
          child: ElevatedButton(
            onPressed: (isLoading || !playEnabled) ? null : onPlay,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Chơi ngay'),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns the API value string for the level at [index] in [levels].
String levelValueAt(int index) => levels[index].value;
