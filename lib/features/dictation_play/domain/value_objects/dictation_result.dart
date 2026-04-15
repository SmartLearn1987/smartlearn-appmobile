import 'package:equatable/equatable.dart';

class DictationResult extends Equatable {
  final int correctWords;
  final int totalWords;

  const DictationResult({
    required this.correctWords,
    required this.totalWords,
  });

  double get accuracy => totalWords > 0 ? correctWords / totalWords : 0.0;

  @override
  List<Object?> get props => [correctWords, totalWords];
}
