import 'package:equatable/equatable.dart';

class ExamEntity extends Equatable {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final int duration;
  final String subjectName;
  final String? educationLevel;
  final String questionCount;
  final String? averageScore;
  final String authorName;
  final bool isPublic;
  final String createdAt;

  const ExamEntity({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.duration,
    required this.subjectName,
    this.educationLevel,
    required this.questionCount,
    required this.averageScore,
    required this.authorName,
    required this.isPublic,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    duration,
    subjectName,
    educationLevel,
    questionCount,
    averageScore,
    authorName,
    isPublic,
    createdAt,
  ];
}
