import 'package:equatable/equatable.dart';

class QuizletTermEntity extends Equatable {
  final String id;
  final String term;
  final String definition;
  final String? imageUrl;
  final int sortOrder;

  const QuizletTermEntity({
    required this.id,
    required this.term,
    required this.definition,
    this.imageUrl,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, term, definition, imageUrl, sortOrder];
}
