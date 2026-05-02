part of 'dictation_play_bloc.dart';

sealed class DictationPlayEvent extends Equatable {
  const DictationPlayEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo game với dữ liệu bài chép chính tả.
final class StartDictation extends DictationPlayEvent {
  final DictationEntity entity;

  const StartDictation({required this.entity});

  @override
  List<Object?> get props => [entity];
}

/// Cập nhật nội dung người dùng gõ.
final class UpdateUserInput extends DictationPlayEvent {
  final String text;

  const UpdateUserInput({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Nộp bài và so sánh kết quả.
final class SubmitAnswer extends DictationPlayEvent {
  const SubmitAnswer();
}

/// Chơi lại — quay về trạng thái nhập liệu với cùng đề bài.
final class PlayAgain extends DictationPlayEvent {
  const PlayAgain();
}

/// Tick mỗi giây để tăng thời gian đã trôi qua.
final class TimerTick extends DictationPlayEvent {
  const TimerTick();
}

/// Lấy ngẫu nhiên một bài chép chính tả khác (cùng level + language).
final class LoadNewDictation extends DictationPlayEvent {
  const LoadNewDictation();
}
