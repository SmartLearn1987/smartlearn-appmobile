import 'package:equatable/equatable.dart';

class WordItem extends Equatable {
  final String id;
  final String word;

  const WordItem({
    required this.id,
    required this.word,
  });

  @override
  List<Object?> get props => [id, word];
}
