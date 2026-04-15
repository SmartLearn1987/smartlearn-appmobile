part of 'dictation_play_bloc.dart';

sealed class DictationPlayState extends Equatable {
  const DictationPlayState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu.
final class DictationPlayInitial extends DictationPlayState {
  const DictationPlayInitial();
}

/// Đang chơi — hiển thị vùng nhập liệu và nút nghe.
final class DictationPlayInProgress extends DictationPlayState {
  final DictationEntity entity;
  final String userInput;
  final bool isPlaying;
  final int wordCount;

  const DictationPlayInProgress({
    required this.entity,
    this.userInput = '',
    this.isPlaying = false,
    this.wordCount = 0,
  });

  @override
  List<Object?> get props => [entity, userInput, isPlaying, wordCount];
}

/// Hoàn thành — hiển thị kết quả so sánh.
final class DictationPlayFinished extends DictationPlayState {
  final DictationEntity entity;
  final String userInput;
  final DictationResult result;
  final List<WordComparison> wordComparisons;

  const DictationPlayFinished({
    required this.entity,
    required this.userInput,
    required this.result,
    required this.wordComparisons,
  });

  @override
  List<Object?> get props => [entity, userInput, result, wordComparisons];
}
