/// Enum representing the current state of the TTS engine.
enum TtsState {
  /// Audio is currently playing.
  playing,

  /// Audio playback is stopped or idle.
  stopped,

  /// An error occurred during TTS operation.
  error,
}

/// Abstract service for Text-to-Speech functionality.
///
/// Provides a contract for TTS implementations, allowing easy
/// mocking in tests and swapping of underlying TTS engines.
abstract class TtsService {
  /// Speaks the given [text] in the specified [language].
  ///
  /// The [language] parameter accepts language codes such as
  /// 'vi' (Vietnamese), 'en' (English), or 'ja' (Japanese).
  Future<void> speak(String text, String language);

  /// Stops any ongoing TTS playback.
  Future<void> stop();

  /// A stream of [TtsState] changes for observing playback status.
  Stream<TtsState> get stateStream;
}
