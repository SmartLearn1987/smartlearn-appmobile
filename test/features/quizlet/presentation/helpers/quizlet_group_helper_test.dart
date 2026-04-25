import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_group_helper.dart';

QuizletEntity _quizlet({
  required String id,
  required String title,
  required String? level,
  required String? subject,
}) {
  return QuizletEntity(
    id: id,
    title: title,
    subjectName: subject,
    educationLevel: level,
    isPublic: true,
    userId: 'u1',
    termCount: 1,
    authorName: 'author',
    createdAt: '2026-01-01',
  );
}

void main() {
  group('groupQuizletsByLevelAndSubject', () {
    test('groups by level then subject and preserves all items', () {
      final input = [
        _quizlet(id: '1', title: 'A', level: 'Tiểu học', subject: 'Toán'),
        _quizlet(id: '2', title: 'B', level: 'Tiểu học', subject: 'Toán'),
        _quizlet(id: '3', title: 'C', level: 'Tiểu học', subject: 'Anh văn'),
      ];

      final grouped = groupQuizletsByLevelAndSubject(input);

      expect(grouped['Tiểu học']!['Toán']!.map((q) => q.id).toList(), ['1', '2']);
      expect(grouped['Tiểu học']!['Anh văn']!.map((q) => q.id).toList(), ['3']);
    });

    test('maps null/blank level and subject to fallback groups', () {
      final input = [
        _quizlet(id: '1', title: 'A', level: null, subject: null),
        _quizlet(id: '2', title: 'B', level: ' ', subject: ' '),
      ];

      final grouped = groupQuizletsByLevelAndSubject(input);
      final uncategorized = grouped['Chưa phân loại'];

      expect(uncategorized, isNotNull);
      expect(
        uncategorized!['Chưa phân loại môn học']!.map((q) => q.id).toList(),
        ['1', '2'],
      );
    });

    test('sorts known level groups by levelOrder', () {
      final input = [
        _quizlet(id: '1', title: 'A', level: 'Đại Học / Cao Đẳng', subject: 'Toán'),
        _quizlet(id: '2', title: 'B', level: 'Tiểu học', subject: 'Toán'),
        _quizlet(id: '3', title: 'C', level: 'Trung học cơ sở', subject: 'Toán'),
      ];

      final grouped = groupQuizletsByLevelAndSubject(input);

      expect(
        grouped.keys.toList(),
        ['Tiểu học', 'Trung học cơ sở', 'Đại Học / Cao Đẳng'],
      );
    });
  });
}
