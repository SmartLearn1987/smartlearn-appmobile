import '../../domain/entities/curriculum_entity.dart';
import '../../domain/entities/subject_entity.dart';
import '../models/subject_with_count.dart';

List<SubjectWithCount> computeSubjectCounts(
  List<SubjectEntity> subjects,
  List<CurriculumEntity> curricula,
  String userId,
) {
  return subjects.map((subject) {
    final count = curricula
        .where((c) => c.userId == userId && c.subjectId == subject.id)
        .length;
    return SubjectWithCount(
      description: subject.description ?? 'Môn học',
      icon: subject.icon ?? '',
      subject: subject,
      userCurriculumCount: count,
    );
  }).toList();
}
