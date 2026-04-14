import '../../../home/domain/entities/subject_entity.dart';
import '../../domain/entities/curriculum_entity.dart';
import '../models/subject_with_count.dart';

List<SubjectWithCount> computeSubjectCounts(
  List<SubjectEntity> subjects,
  List<CurriculumEntity> curricula,
  String userId,
) {
  return subjects.map((subject) {
    final count = curricula
        .where(
          (c) => c.createdBy == userId && c.subjectId == subject.id,
        )
        .length;
    return SubjectWithCount(
      subject: subject,
      icon: subject.icon ?? '',
      description: subject.description ?? 'Môn học',
      userCurriculumCount: count,
    );
  }).toList();
}
