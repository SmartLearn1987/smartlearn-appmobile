import 'package:equatable/equatable.dart';

class ExamOptionEntity extends Equatable {
  final String id;
  final String content;
  final bool isCorrect;
  final int sortOrder;

  const ExamOptionEntity({
    required this.id,
    required this.content,
    required this.isCorrect,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, content, isCorrect, sortOrder];
}
