import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String? lessonId;
  final String front;
  final String back;

  const Flashcard({
    required this.id,
    this.lessonId,
    required this.front,
    required this.back,
  });

  @override
  List<Object?> get props => [id, lessonId, front, back];
}
