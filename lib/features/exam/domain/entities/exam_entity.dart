import 'package:equatable/equatable.dart';

class ExamEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int duration;
  final String subjectName;
  final String questionCount;
  final double? averageScore;
  final String authorName;
  final bool isPublic;
  final String createdAt;

  const ExamEntity({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.subjectName,
    required this.questionCount,
    this.averageScore,
    required this.authorName,
    required this.isPublic,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        duration,
        subjectName,
        questionCount,
        averageScore,
        authorName,
        isPublic,
        createdAt,
      ];
}
