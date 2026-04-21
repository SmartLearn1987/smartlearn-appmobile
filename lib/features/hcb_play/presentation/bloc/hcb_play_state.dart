part of 'hcb_play_bloc.dart';

sealed class HCBPlayState extends Equatable {
  const HCBPlayState();

  @override
  List<Object?> get props => [];
}

final class HCBInitial extends HCBPlayState {
  const HCBInitial();
}

final class HCBLoading extends HCBPlayState {
  const HCBLoading();
}

final class HCBInProgress extends HCBPlayState {
  final List<LearningQuestionEntity> questions;
  final String generalQuestion;
  final int currentIndex;
  final bool isFlipped;
  final bool isAutoPlaying;

  const HCBInProgress({
    required this.questions,
    required this.generalQuestion,
    required this.currentIndex,
    required this.isFlipped,
    required this.isAutoPlaying,
  });

  HCBInProgress copyWith({
    List<LearningQuestionEntity>? questions,
    String? generalQuestion,
    int? currentIndex,
    bool? isFlipped,
    bool? isAutoPlaying,
  }) {
    return HCBInProgress(
      questions: questions ?? this.questions,
      generalQuestion: generalQuestion ?? this.generalQuestion,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isAutoPlaying: isAutoPlaying ?? this.isAutoPlaying,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        generalQuestion,
        currentIndex,
        isFlipped,
        isAutoPlaying,
      ];
}

final class HCBError extends HCBPlayState {
  final String message;

  const HCBError({required this.message});

  @override
  List<Object?> get props => [message];
}
