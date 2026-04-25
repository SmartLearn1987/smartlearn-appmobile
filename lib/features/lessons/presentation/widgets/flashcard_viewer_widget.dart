import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/flashcard.dart';

/// Widget hiển thị flashcard với hiệu ứng lật 3D và điều hướng giữa các thẻ.
class FlashcardViewerWidget extends StatefulWidget {
  const FlashcardViewerWidget({
    super.key,
    required this.flashcards,
  });

  final List<Flashcard> flashcards;

  @override
  State<FlashcardViewerWidget> createState() => _FlashcardViewerWidgetState();
}

class _FlashcardViewerWidgetState extends State<FlashcardViewerWidget>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.flashcards.length - 1;

  Flashcard get _currentCard => widget.flashcards[_currentIndex];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;

    if (_showBack) {
      _flipController.reverse().then((_) {
        setState(() => _showBack = false);
      });
    } else {
      _flipController.forward().then((_) {
        setState(() => _showBack = true);
      });
    }
  }

  void _goToPrevious() {
    if (!_hasPrevious) return;
    _resetFlip();
    setState(() => _currentIndex--);
  }

  void _goToNext() {
    if (!_hasNext) return;
    _resetFlip();
    setState(() => _currentIndex++);
  }

  void _resetFlip() {
    _flipController.reset();
    _showBack = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card counter badge
        _buildCardCounter(),
        const SizedBox(height: AppSpacing.md),

        // Flip card
        _buildFlipCard(),
        const SizedBox(height: AppSpacing.sm),

        // Tap hint
        Center(
          child: Text(
            'Nhấn vào thẻ để lật',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Navigation controls
        _buildNavigation(),
      ],
    );
  }

  Widget _buildCardCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Text(
        'Thẻ ${_currentIndex + 1}/${widget.flashcards.length}',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildFlipCard() {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final isFrontVisible = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildCardFace(
                    text: _currentCard.front,
                    label: 'Thuật ngữ',
                    icon: LucideIcons.bookOpen,
                    backgroundColor: AppColors.card,
                    accentColor: AppColors.accent,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardFace(
                      text: _currentCard.back,
                      label: 'Định nghĩa',
                      icon: LucideIcons.lightbulb,
                      backgroundColor: AppColors.accentLight,
                      accentColor: AppColors.accent,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({
    required String text,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Card text
          Text(
            text,
            style: AppTypography.h4.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        IconButton(
          onPressed: _hasPrevious ? _goToPrevious : null,
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          style: IconButton.styleFrom(
            backgroundColor:
                _hasPrevious ? AppColors.muted : Colors.transparent,
            foregroundColor:
                _hasPrevious ? AppColors.foreground : AppColors.mutedForeground,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadiusSm,
            ),
          ),
        ),

        // Card counter text
        Text(
          '${_currentIndex + 1} / ${widget.flashcards.length}',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),

        // Next button
        IconButton(
          onPressed: _hasNext ? _goToNext : null,
          icon: const Icon(LucideIcons.chevronRight, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: _hasNext ? AppColors.muted : Colors.transparent,
            foregroundColor:
                _hasNext ? AppColors.foreground : AppColors.mutedForeground,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadiusSm,
            ),
          ),
        ),
      ],
    );
  }
}
