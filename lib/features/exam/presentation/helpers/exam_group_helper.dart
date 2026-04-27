import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';

const examLevelOrder = [
  'Tiểu học',
  'Trung học cơ sở',
  'Trung học Phổ Thông',
  'Đại Học / Cao Đẳng',
  'Luyện thi chứng chỉ',
  'Chưa phân loại',
];

Map<String, Map<String, List<ExamEntity>>> groupExamsByLevelAndSubject(
  List<ExamEntity> exams,
) {
  final grouped = <String, Map<String, List<ExamEntity>>>{};

  for (final exam in exams) {
    final level = exam.educationLevel?.trim().isNotEmpty == true
        ? exam.educationLevel!.trim()
        : 'Chưa phân loại';
    final subject = exam.subjectName.trim().isNotEmpty
        ? exam.subjectName.trim()
        : 'Chưa phân loại môn học';

    grouped.putIfAbsent(level, () => <String, List<ExamEntity>>{});
    grouped[level]!.putIfAbsent(subject, () => <ExamEntity>[]);
    grouped[level]![subject]!.add(exam);
  }

  final ordered = <String, Map<String, List<ExamEntity>>>{};
  for (final level in examLevelOrder) {
    if (grouped.containsKey(level)) {
      ordered[level] = grouped[level]!;
    }
  }

  final remainingLevels =
      grouped.keys.where((level) => !ordered.containsKey(level)).toList()
        ..sort();
  for (final level in remainingLevels) {
    ordered[level] = grouped[level]!;
  }

  return ordered;
}
