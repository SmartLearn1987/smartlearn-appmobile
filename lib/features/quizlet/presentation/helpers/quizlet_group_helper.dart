import 'dart:collection';

import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

const levelOrder = [
  'Tiểu học',
  'Trung học cơ sở',
  'Trung học Phổ Thông',
  'Đại Học / Cao Đẳng',
  'Luyện thi chứng chỉ',
  'Chưa phân loại',
];

Map<String, Map<String, List<QuizletEntity>>> groupQuizletsByLevelAndSubject(
  List<QuizletEntity> quizlets,
) {
  final grouped = <String, Map<String, List<QuizletEntity>>>{};

  for (final quizlet in quizlets) {
    final level = quizlet.educationLevel?.trim().isNotEmpty == true
        ? quizlet.educationLevel!.trim()
        : 'Chưa phân loại';
    final subject = quizlet.subjectName?.trim().isNotEmpty == true
        ? quizlet.subjectName!.trim()
        : 'Chưa phân loại môn học';

    grouped.putIfAbsent(level, () => <String, List<QuizletEntity>>{});
    grouped[level]!.putIfAbsent(subject, () => <QuizletEntity>[]);
    grouped[level]![subject]!.add(quizlet);
  }

  final ordered = LinkedHashMap<String, Map<String, List<QuizletEntity>>>();
  for (final level in levelOrder) {
    if (grouped.containsKey(level)) {
      ordered[level] = grouped[level]!;
    }
  }

  final remainingLevels = grouped.keys
      .where((level) => !ordered.containsKey(level))
      .toList()
    ..sort();
  for (final level in remainingLevels) {
    ordered[level] = grouped[level]!;
  }

  return ordered;
}
