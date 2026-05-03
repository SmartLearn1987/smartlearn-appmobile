import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/flashcard.dart';
import '../widgets/flashcard_flip_view.dart';

/// Toàn màn hình học flashcard bài học (giống luồng Quizlet fullscreen).
class LessonFlashcardsFullscreenPage extends StatefulWidget {
  const LessonFlashcardsFullscreenPage({
    super.key,
    required this.initialDeck,
    required this.initialIndex,
    required this.initialFlipped,
    required this.initialShuffled,
    required this.sourceFlashcards,
  });

  final List<Flashcard> initialDeck;
  final int initialIndex;
  final bool initialFlipped;
  final bool initialShuffled;
  final List<Flashcard> sourceFlashcards;

  @override
  State<LessonFlashcardsFullscreenPage> createState() =>
      _LessonFlashcardsFullscreenPageState();
}

class _LessonFlashcardsFullscreenPageState
    extends State<LessonFlashcardsFullscreenPage> {
  late List<Flashcard> _deck;
  late int _currentIndex;
  bool _isFlipped = false;
  bool _isPlaying = false;
  bool _isShuffled = false;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.initialDeck);
    _currentIndex = widget.initialIndex.clamp(0, _deck.length - 1);
    _isFlipped = widget.initialFlipped;
    _isShuffled = widget.initialShuffled;
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
        _deck = List.of(widget.sourceFlashcards);
        _isShuffled = false;
      } else {
        _deck = List.of(widget.sourceFlashcards)..shuffle(Random());
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
    if (_deck.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Text(
              'Chưa có thẻ',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
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
                        onPressed: () => context.pop(),
                        icon: LucideIcons.minimize2,
                        tooltip: 'Thoát',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
