import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

import 'tts_service.dart';

/// Language code to locale mapping for TTS engine.
const _languageLocaleMap = <String, String>{
  'vi': 'vi-VN',
  'en': 'en-US',
  'ja': 'ja-JP',
};

/// Default locale used when the requested language is not supported.
const _defaultLocale = 'en-US';

/// Concrete implementation of [TtsService] using the `flutter_tts` package.
///
/// Registered as a lazy singleton so a single instance is shared across
/// the app and the underlying [FlutterTts] engine is reused.
@LazySingleton(as: TtsService)
class TtsServiceImpl implements TtsService {
  TtsServiceImpl(this._flutterTts) {
    _setupHandlers();
  }

  final FlutterTts _flutterTts;
  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();

  @override
  Stream<TtsState> get stateStream => _stateController.stream;

  @override
  Future<void> speak(String text, String language) async {
    final locale = _languageLocaleMap[language] ?? _defaultLocale;

    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(locale);
      if (isAvailable == true) {
        await _flutterTts.setLanguage(locale);
      } else {
        await _flutterTts.setLanguage(_defaultLocale);
      }
    } catch (_) {
      await _flutterTts.setLanguage(_defaultLocale);
    }

    _stateController.add(TtsState.playing);
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
    _stateController.add(TtsState.stopped);
  }

  void _setupHandlers() {
    _flutterTts.setStartHandler(() {
      _stateController.add(TtsState.playing);
    });

    _flutterTts.setCompletionHandler(() {
      _stateController.add(TtsState.stopped);
    });

    _flutterTts.setErrorHandler((message) {
      _stateController.add(TtsState.error);
    });
  }
}
