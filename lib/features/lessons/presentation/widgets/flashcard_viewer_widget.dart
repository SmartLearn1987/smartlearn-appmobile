import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/flashcard.dart';
import '../pages/lesson_flashcards_fullscreen_page.dart';
import 'flashcard_flip_view.dart';

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
  final GlobalKey _cardKey = GlobalKey();

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

  void _pushFullscreen(BuildContext context) {
    final ctx = _cardKey.currentContext;
    final ro = ctx?.findRenderObject();
    final renderBox = ro is RenderBox ? ro : null;
    final cardRect = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : Rect.zero;
    final screenSize = MediaQuery.sizeOf(context);

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LessonFlashcardsFullscreenPage(
              initialDeck: List.of(_deck),
              initialIndex: _currentIndex,
              initialFlipped: _isFlipped,
              initialShuffled: _isShuffled,
              sourceFlashcards: List.of(widget.flashcards),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final scaleX = Tween<double>(
            begin: cardRect.width / screenSize.width,
            end: 1.0,
          ).animate(curved);
          final scaleY = Tween<double>(
            begin: cardRect.height / screenSize.height,
            end: 1.0,
          ).animate(curved);
          final dx = Tween<double>(
            begin:
                (cardRect.left + cardRect.width / 2 - screenSize.width / 2) /
                screenSize.width,
            end: 0.0,
          ).animate(curved);
          final dy = Tween<double>(
            begin:
                (cardRect.top + cardRect.height / 2 - screenSize.height / 2) /
                screenSize.height,
            end: 0.0,
          ).animate(curved);
          final radius = Tween<double>(begin: 16.0, end: 0.0).animate(curved);

          return AnimatedBuilder(
            animation: curved,
            builder: (context, animChild) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(
                  dx.value * screenSize.width,
                  dy.value * screenSize.height,
                )
                ..scale(scaleX.value, scaleY.value),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius.value),
                child: animChild,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: _cardKey,
          width: double.infinity,
          child: FlashcardFlipView(
            key: ValueKey(_currentIndex),
            front: _currentCard.front,
            back: _currentCard.back,
            isFlipped: _isFlipped,
            onFlip: _flip,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlashcardDeckControlIconButton(
                  onPressed: _togglePlay,
                  icon: _isPlaying ? LucideIcons.pause : LucideIcons.play,
                ),
                FlashcardDeckControlIconButton(
                  onPressed: _shuffle,
                  icon: LucideIcons.shuffle,
                  iconColor: _isShuffled ? AppColors.primary : null,
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlashcardDeckControlIconButton(
                    onPressed: _hasPrevious ? _goToPrevious : null,
                    icon: LucideIcons.chevronLeft,
                  ),
                  Text(
                    '${_currentIndex + 1} / ${_deck.length}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  FlashcardDeckControlIconButton(
                    onPressed: _hasNext ? _goToNext : null,
                    icon: LucideIcons.chevronRight,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 32),
                FlashcardDeckControlIconButton(
                  onPressed: widget.flashcards.isEmpty
                      ? null
                      : () => _pushFullscreen(context),
                  icon: LucideIcons.maximize2,
                  tooltip: 'Toàn màn hình',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
