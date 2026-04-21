part of 'hcb_play_bloc.dart';

sealed class HCBPlayEvent extends Equatable {
  const HCBPlayEvent();

  @override
  List<Object?> get props => [];
}

final class StartGame extends HCBPlayEvent {
  final List<LearningQuestionEntity> questions;
  final String generalQuestion;

  const StartGame({
    required this.questions,
    required this.generalQuestion,
  });

  @override
  List<Object?> get props => [questions, generalQuestion];
}

final class FlipCard extends HCBPlayEvent {
  const FlipCard();
}

final class NextCard extends HCBPlayEvent {
  const NextCard();
}

final class PreviousCard extends HCBPlayEvent {
  const PreviousCard();
}

final class ToggleAutoPlay extends HCBPlayEvent {
  const ToggleAutoPlay();
}

final class ShuffleCards extends HCBPlayEvent {
  const ShuffleCards();
}

/// Internal event used by auto-play timer to advance to the next card.
/// Unlike [NextCard], this does not deactivate auto-play.
final class _AutoPlayAdvance extends HCBPlayEvent {
  const _AutoPlayAdvance();
}

/// Internal event used by auto-play timer to flip the card.
/// Unlike [FlipCard], this is only triggered by the auto-play cycle.
final class _AutoPlayFlip extends HCBPlayEvent {
  const _AutoPlayFlip();
}
