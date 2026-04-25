import 'package:equatable/equatable.dart';

class TermParams extends Equatable {
  final String term;
  final String definition;

  const TermParams({
    required this.term,
    required this.definition,
  });

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'definition': definition,
    };
  }

  factory TermParams.fromJson(Map<String, dynamic> json) {
    return TermParams(
      term: json['term'] as String,
      definition: json['definition'] as String,
    );
  }

  @override
  List<Object?> get props => [term, definition];
}

class CreateQuizletParams extends Equatable {
  final String title;
  final String? description;
  final String? subjectId;
  final String? grade;
  final String? educationLevel;
  final bool isPublic;
  final String createdBy;
  final List<TermParams> terms;

  const CreateQuizletParams({
    required this.title,
    this.description,
    this.subjectId,
    this.grade,
    this.educationLevel,
    required this.isPublic,
    required this.createdBy,
    required this.terms,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'grade': grade,
      'education_level': educationLevel,
      'is_public': isPublic,
      'created_by': createdBy,
      'terms': terms.map((t) => t.toJson()).toList(),
    };
  }

  factory CreateQuizletParams.fromJson(Map<String, dynamic> json) {
    return CreateQuizletParams(
      title: json['title'] as String,
      description: json['description'] as String?,
      subjectId: json['subject_id'] as String?,
      grade: json['grade'] as String?,
      educationLevel: json['education_level'] as String?,
      isPublic: json['is_public'] as bool,
      createdBy: json['created_by'] as String,
      terms: (json['terms'] as List<dynamic>)
          .map((t) => TermParams.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        subjectId,
        grade,
        educationLevel,
        isPublic,
        createdBy,
        terms,
      ];
}
