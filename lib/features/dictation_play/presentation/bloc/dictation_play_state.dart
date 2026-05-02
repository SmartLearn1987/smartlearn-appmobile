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

/// Đang chơi — hiển thị đề bài + vùng nhập liệu.
final class DictationPlayInProgress extends DictationPlayState {
  final DictationEntity entity;
  final String userInput;
  final int wordCount;

  /// Số giây đã trôi qua kể từ khi bắt đầu / load bài.
  final int elapsedSeconds;

  /// Đang load bài mới (nút "Bài khác" bị disable + spinner).
  final bool isLoadingNew;

  /// Lỗi gần nhất khi load bài mới (UI lắng nghe để show toast).
  final String? errorMessage;

  const DictationPlayInProgress({
    required this.entity,
    this.userInput = '',
    this.wordCount = 0,
    this.elapsedSeconds = 0,
    this.isLoadingNew = false,
    this.errorMessage,
  });

  DictationPlayInProgress copyWith({
    DictationEntity? entity,
    String? userInput,
    int? wordCount,
    int? elapsedSeconds,
    bool? isLoadingNew,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DictationPlayInProgress(
      entity: entity ?? this.entity,
      userInput: userInput ?? this.userInput,
      wordCount: wordCount ?? this.wordCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isLoadingNew: isLoadingNew ?? this.isLoadingNew,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    entity,
    userInput,
    wordCount,
    elapsedSeconds,
    isLoadingNew,
    errorMessage,
  ];
}

/// Hoàn thành — hiển thị kết quả so sánh.
final class DictationPlayFinished extends DictationPlayState {
  final DictationEntity entity;
  final String userInput;
  final DictationResult result;
  final List<WordComparison> wordComparisons;
  final int elapsedSeconds;

  /// Đang load bài mới (nút "Bài mới" disable + spinner).
  final bool isLoadingNew;

  /// Lỗi gần nhất khi load bài mới.
  final String? errorMessage;

  const DictationPlayFinished({
    required this.entity,
    required this.userInput,
    required this.result,
    required this.wordComparisons,
    required this.elapsedSeconds,
    this.isLoadingNew = false,
    this.errorMessage,
  });

  DictationPlayFinished copyWith({
    bool? isLoadingNew,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DictationPlayFinished(
      entity: entity,
      userInput: userInput,
      result: result,
      wordComparisons: wordComparisons,
      elapsedSeconds: elapsedSeconds,
      isLoadingNew: isLoadingNew ?? this.isLoadingNew,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    entity,
    userInput,
    result,
    wordComparisons,
    elapsedSeconds,
    isLoadingNew,
    errorMessage,
  ];
}
