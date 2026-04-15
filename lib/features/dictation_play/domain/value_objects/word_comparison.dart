import 'package:equatable/equatable.dart';

class WordComparison extends Equatable {
  final String originalWord;
  final String? userWord;
  final bool isCorrect;

  const WordComparison({
    required this.originalWord,
    required this.userWord,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [originalWord, userWord, isCorrect];
}
