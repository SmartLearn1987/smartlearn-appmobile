import 'package:equatable/equatable.dart';

class LessonProgress extends Equatable {
  final String lessonId;
  final bool completed;
  final DateTime? completedAt;

  const LessonProgress({
    required this.lessonId,
    required this.completed,
    this.completedAt,
  });

  @override
  List<Object?> get props => [lessonId, completed, completedAt];
}
