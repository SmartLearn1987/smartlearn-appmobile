import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/flashcard.dart';

class FlashcardViewerWidget extends StatefulWidget {
  const FlashcardViewerWidget({super.key, required this.flashcards});

  final List<Flashcard> flashcards;

  @override
  State<FlashcardViewerWidget> createState() => _FlashcardViewerWidgetState();
}

class _FlashcardViewerWidgetState extends State<FlashcardViewerWidget> {
  late List<Flashcard> _deck;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isPlaying = false;
  bool _isShuffled = false;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.flashcards);
  }

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < _deck.length - 1;
  Flashcard get _currentCard => _deck[_currentIndex];

  void _flip() => setState(() => _isFlipped = !_isFlipped);

  void _goToPrevious() {
    if (!_hasPrevious) return;
    setState(() {
      _currentIndex--;
      _isFlipped = false;
    });
  }

  void _goToNext() {
    if (!_hasNext) return;
    setState(() {
      _currentIndex++;
      _isFlipped = false;
    });
  }

  void _shuffle() {
    setState(() {
      if (_isShuffled) {
        _deck = List.of(widget.flashcards);
        _isShuffled = false;
      } else {
        _deck = List.of(widget.flashcards)..shuffle(Random());
        _isShuffled = true;
      }
      _currentIndex = 0;
      _isFlipped = false;
      _isPlaying = false;
    });
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) _autoPlay();
  }

  Future<void> _autoPlay() async {
    while (_isPlaying && mounted) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted || !_isPlaying) break;
      setState(() => _isFlipped = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted || !_isPlaying) break;
      if (_hasNext) {
        setState(() {
          _currentIndex++;
          _isFlipped = false;
        });
      } else {
        setState(() {
          _isPlaying = false;
          _isFlipped = false;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlashcardItem(
          key: ValueKey(_currentIndex),
          front: _currentCard.front,
          back: _currentCard.back,
          isFlipped: _isFlipped,
          onFlip: _flip,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  iconSize: 20,
                  onPressed: _togglePlay,
                  icon: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play),
                ),
                IconButton(
                  onPressed: _shuffle,
                  iconSize: 20,
                  icon: Icon(
                    LucideIcons.shuffle,
                    color: _isShuffled ? AppColors.primary : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _hasPrevious ? _goToPrevious : null,
                  icon: const Icon(LucideIcons.chevronLeft),
                ),
                Text(
                  '${_currentIndex + 1} / ${_deck.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: _hasNext ? _goToNext : null,
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ],
            ),
            const SizedBox(width: 96),
          ],
        ),
      ],
    );
  }
}

class _FlashcardItem extends StatefulWidget {
  const _FlashcardItem({
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
  State<_FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<_FlashcardItem>
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
  void didUpdateWidget(covariant _FlashcardItem oldWidget) {
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
