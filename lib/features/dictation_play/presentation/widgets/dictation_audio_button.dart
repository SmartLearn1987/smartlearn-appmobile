import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';

/// A button that triggers audio playback for dictation content.
///
/// Displays a speaker icon that animates (pulses) while audio is playing.
/// The button is disabled during playback to prevent overlapping audio.
class DictationAudioButton extends StatefulWidget {
  const DictationAudioButton({
    required this.isPlaying,
    required this.onPressed,
    super.key,
  });

  /// Whether audio is currently playing.
  final bool isPlaying;

  /// Callback when the button is tapped. Null disables the button.
  final VoidCallback? onPressed;

  @override
  State<DictationAudioButton> createState() => _DictationAudioButtonState();
}

class _DictationAudioButtonState extends State<DictationAudioButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant DictationAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isPlaying || widget.onPressed == null;

    return GestureDetector(
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = widget.isPlaying ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.isPlaying
                ? AppColors.accent
                : AppColors.accentLight,
            borderRadius: AppBorders.borderRadiusFull,
            border: Border.all(
              color: widget.isPlaying
                  ? AppColors.accent
                  : AppColors.accent.withValues(alpha: 0.3),
              width: AppBorders.widthMedium,
            ),
          ),
          child: Icon(
            widget.isPlaying ? LucideIcons.volume2 : LucideIcons.volume1,
            size: 28,
            color: widget.isPlaying
                ? AppColors.accentForeground
                : AppColors.accent,
          ),
        ),
      ),
    );
  }
}
