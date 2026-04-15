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

/// Phát âm thanh lần đầu.
final class PlayAudio extends DictationPlayEvent {
  const PlayAudio();
}

/// Phát lại âm thanh.
final class ReplayAudio extends DictationPlayEvent {
  const ReplayAudio();
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

/// Chơi lại (quay về trang chủ).
final class PlayAgain extends DictationPlayEvent {
  const PlayAgain();
}

/// Internal event — TTS playback state changed.
final class _TtsStateChanged extends DictationPlayEvent {
  final TtsState ttsState;

  const _TtsStateChanged({required this.ttsState});

  @override
  List<Object?> get props => [ttsState];
}
