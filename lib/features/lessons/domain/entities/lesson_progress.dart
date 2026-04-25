import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  final String id;
  final String studentId;
  final String lessonId;
  final bool completed;
  final DateTime? completedAt;

  const LessonProgress({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.completed,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, studentId, lessonId, completed, completedAt];
}
