import 'package:equatable/equatable.dart';

class VocabularyItem extends Equatable {
  final String term;
  final String definition;

  const VocabularyItem({
    required this.term,
    required this.definition,
  });

  @override
  List<Object?> get props => [term, definition];
}
