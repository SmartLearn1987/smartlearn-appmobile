import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

@module
abstract class TtsModule {
  @lazySingleton
  FlutterTts get flutterTts => FlutterTts();
}
