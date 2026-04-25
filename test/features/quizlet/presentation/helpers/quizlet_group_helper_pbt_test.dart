// Tag: Feature: quizlet-flashcard, Property 5: Nhóm theo Cấp học → Môn học
@Tags(['quizlet-flashcard-property-5'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_group_helper.dart';

Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

Generator<String?> get _optionalEducationLevel =>
    any.choose(<String?>[null, '', ...levelOrder, 'Khác']);

Generator<String?> get _optionalSubject =>
    any.choose(<String?>[null, '', 'Toán', 'Anh văn', 'Vật lý']);

Generator<QuizletEntity> get _quizletEntity => any.combine5(
      _nonEmptyString,
      _nonEmptyString,
      _optionalSubject,
      _optionalEducationLevel,
      any.bool,
      (
        String id,
        String title,
        String? subjectName,
        String? educationLevel,
        bool isPublic,
      ) =>
          (
        id: id,
        title: title,
        subjectName: subjectName,
        educationLevel: educationLevel,
        isPublic: isPublic,
      ),
    ).bind(
      (base) => any.combine4(
        _nonEmptyString,
        any.intInRange(0, 100),
        _nonEmptyString,
        _nonEmptyString,
        (String userId, int termCount, String authorName, String createdAt) =>
            QuizletEntity(
          id: base.id,
          title: base.title,
          subjectName: base.subjectName,
          educationLevel: base.educationLevel,
          isPublic: base.isPublic,
          userId: userId,
          termCount: termCount,
          authorName: authorName,
          createdAt: createdAt,
        ),
      ),
    );

void main() {
  group('Property 5: Nhóm bảo toàn dữ liệu và thứ tự', () {
    Glados(
      any.listWithLengthInRange(0, 50, _quizletEntity),
      ExploreConfig(numRuns: 100),
    ).test(
      'grouping bảo toàn phần tử và giữ thứ tự levelOrder',
      (quizlets) {
        final grouped = groupQuizletsByLevelAndSubject(quizlets);

        final flattened = grouped.values
            .expand((subjectMap) => subjectMap.values.expand((items) => items))
            .toList();
        expect(
          flattened.length,
          equals(quizlets.length),
          reason: 'Total number of grouped quizlets must equal input length',
        );

        for (final entry in grouped.entries) {
          final level = entry.key;
          for (final subjectEntry in entry.value.entries) {
            final subject = subjectEntry.key;
            for (final quizlet in subjectEntry.value) {
              final normalizedLevel = quizlet.educationLevel?.trim().isNotEmpty == true
                  ? quizlet.educationLevel!.trim()
                  : 'Chưa phân loại';
              final normalizedSubject = quizlet.subjectName?.trim().isNotEmpty == true
                  ? quizlet.subjectName!.trim()
                  : 'Chưa phân loại môn học';
              expect(normalizedLevel, equals(level));
              expect(normalizedSubject, equals(subject));
            }
          }
        }

        final groupedLevels = grouped.keys.toList();
        final indexedKnownLevels = groupedLevels
            .where(levelOrder.contains)
            .map(levelOrder.indexOf)
            .toList();
        final sortedKnownLevels = [...indexedKnownLevels]..sort();
        expect(
          indexedKnownLevels,
          equals(sortedKnownLevels),
          reason: 'Known education levels must follow levelOrder',
        );

        final hasUncategorizedInput = quizlets.any(
          (q) => q.educationLevel == null || q.educationLevel!.trim().isEmpty,
        );
        if (hasUncategorizedInput) {
          expect(grouped.containsKey('Chưa phân loại'), isTrue);
        }
      },
    );
  });
}
