import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/quizlet_term_entity.dart';

/// A flashcard widget with 3D flip animation.
///
/// Displays the front side (term + optional image) and back side (definition)
/// of a [QuizletTermEntity]. Flips with a 3D rotation around the Y axis
/// when [isFlipped] changes.
class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    required this.term,
    required this.isFlipped,
    required this.onFlip,
    super.key,
  });

  /// The term entity containing front/back content.
  final QuizletTermEntity term;

  /// Whether the card is currently showing the back (definition) side.
  final bool isFlipped;

  /// Callback invoked when the user taps the card to flip it.
  final VoidCallback onFlip;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
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

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
                ? _FlashcardBack(definition: widget.term.definition)
                : _FlashcardFront(
                    term: widget.term.term,
                    imageUrl: widget.term.imageUrl,
                  ),
          );
        },
      ),
    );
  }
}

/// Front side of the flashcard showing the term and optional image.
class _FlashcardFront extends StatelessWidget {
  const _FlashcardFront({required this.term, this.imageUrl});

  final String term;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fontSize = _adaptiveFontSize(term, context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                AppCachedImage(
                  imageUrl: imageUrl!,
                  height: 120,
                  borderRadius: AppBorders.borderRadiusMd,
                  errorWidget: const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                term,
                style: AppTypography.h3.copyWith(
                  color: AppColors.destructive,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back side of the flashcard showing the definition.
///
/// Applies an additional `rotateY(pi)` so text reads correctly
/// when the parent transform has rotated past 180°.
class _FlashcardBack extends StatelessWidget {
  const _FlashcardBack({required this.definition});

  final String definition;

  @override
  Widget build(BuildContext context) {
    final fontSize = _adaptiveFontSize(definition, context);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Center(
              child: Text(
                definition,
                style: AppTypography.h3.copyWith(
                  color: Colors.blue.shade700,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
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
