part of 'cdtn_play_bloc.dart';

enum CheckStatus { correct, incorrect }

sealed class CDTNPlayState extends Equatable {
  const CDTNPlayState();

  @override
  List<Object?> get props => [];
}

final class CDTNPlayInitial extends CDTNPlayState {
  const CDTNPlayInitial();
}

final class CDTNPlayInProgress extends CDTNPlayState {
  final List<ProverbEntity> questions;
  final int currentIndex;
  final int remainingSeconds;

  /// Pool gốc (đã shuffle) cho từng câu — dùng để hiển thị các từ chưa chọn.
  final List<List<WordItem>> allWords;

  /// Danh sách từ người chơi đã chọn cho từng câu (theo thứ tự).
  final List<List<WordItem>> userWordArrangements;

  final CheckStatus? checkStatus;

  const CDTNPlayInProgress({
    required this.questions,
    required this.currentIndex,
    required this.remainingSeconds,
    required this.allWords,
    required this.userWordArrangements,
    this.checkStatus,
  });

  /// Các từ còn lại trong pool của câu [qIndex] (đã loại các từ đã chọn).
  List<WordItem> poolFor(int qIndex) {
    final selectedIds =
        userWordArrangements[qIndex].map((w) => w.id).toSet();
    return allWords[qIndex]
        .where((w) => !selectedIds.contains(w.id))
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        remainingSeconds,
        allWords,
        userWordArrangements,
        checkStatus,
      ];
}

final class CDTNPlayFinished extends CDTNPlayState {
  final List<ProverbEntity> questions;
  final List<List<WordItem>> userWordArrangements;
  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;

  const CDTNPlayFinished({
    required this.questions,
    required this.userWordArrangements,
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [
        questions,
        userWordArrangements,
        correctCount,
        totalQuestions,
        elapsedSeconds,
      ];
}
