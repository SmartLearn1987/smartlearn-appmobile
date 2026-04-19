import 'package:equatable/equatable.dart';

class QuizletEntity extends Equatable {
  final String id;
  final String title;
  final String? subjectName;
  final String? educationLevel;
  final bool isPublic;
  final String userId;
  final int termCount;
  final String authorName;
  final String createdAt;

  const QuizletEntity({
    required this.id,
    required this.title,
    this.subjectName,
    this.educationLevel,
    required this.isPublic,
    required this.userId,
    required this.termCount,
    required this.authorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subjectName,
        educationLevel,
        isPublic,
        userId,
        termCount,
        authorName,
        createdAt,
      ];
}
