import 'package:equatable/equatable.dart';

import 'create_quizlet_params.dart';

class UpdateQuizletParams extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? subjectId;
  final String? grade;
  final String? educationLevel;
  final bool isPublic;
  final List<TermParams> terms;

  const UpdateQuizletParams({
    required this.id,
    required this.title,
    this.description,
    this.subjectId,
    this.grade,
    this.educationLevel,
    required this.isPublic,
    required this.terms,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'grade': grade,
      'education_level': educationLevel,
      'is_public': isPublic,
      'terms': terms.map((t) => t.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        subjectId,
        grade,
        educationLevel,
        isPublic,
        terms,
      ];
}
