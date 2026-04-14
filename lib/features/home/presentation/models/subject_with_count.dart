import 'package:equatable/equatable.dart';

import '../../domain/entities/subject_entity.dart';

class SubjectWithCount extends Equatable {
  final SubjectEntity subject;
  final String icon;
  final String description;
  final int userCurriculumCount;

  const SubjectWithCount({
    required this.subject,
    required this.icon,
    required this.description,
    required this.userCurriculumCount,
  });

  @override
  List<Object?> get props => [subject, icon, description, userCurriculumCount];
}
