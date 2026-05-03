import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Nút 32×32 — đồng bộ với hàng điều khiển flashcard (quizlet detail).
class FlashcardDeckControlIconButton extends StatelessWidget {
  const FlashcardDeckControlIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final String? tooltip;

  static const double size = 32;
  static const double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: IconButton(
        iconSize: iconSize,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        style: IconButton.styleFrom(padding: EdgeInsets.zero),
        icon: Icon(icon, color: iconColor),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class FlashcardFlipView extends StatefulWidget {
  const FlashcardFlipView({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onFlip,
  });

  final String front;
  final String back;
  final bool isFlipped;
  final VoidCallback onFlip;

  @override
  State<FlashcardFlipView> createState() => _FlashcardFlipViewState();
}

class _FlashcardFlipViewState extends State<FlashcardFlipView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.isFlipped) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant FlashcardFlipView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      widget.isFlipped ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          final showBack = _animation.value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? _CardBack(text: widget.back)
                : _CardFront(text: widget.front),
          );
        },
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: AppColors.card,
      child: Center(
        child: Text(
          text,
          style: AppTypography.h3.copyWith(
            color: AppColors.destructive,
            fontSize: _adaptiveFontSize(text, context),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: _CardShell(
        color: AppColors.card,
        child: Center(
          child: Text(
            text,
            style: AppTypography.h3.copyWith(
              color: Colors.blue.shade700,
              fontSize: _adaptiveFontSize(text, context),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

double _adaptiveFontSize(String text, BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  var size = width < 380 ? 26.0 : 32.0;
  final length = text.trim().length;

  if (length > 120) {
    size = width < 380 ? 16 : 18;
  } else if (length > 70) {
    size = width < 380 ? 18 : 22;
  } else if (length > 40) {
    size = width < 380 ? 20 : 26;
  }

  return size;
}
