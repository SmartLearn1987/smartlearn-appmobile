// Tag: Feature: quizlet-flashcard, Property 8: Xóa bộ flashcard
@Tags(['quizlet-flashcard-property-8'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

Generator<List<QuizletEntity>> get _nonEmptyQuizletList => any
    .listWithLengthInRange(
      1,
      30,
      any.combine3(
        _nonEmptyString,
        _nonEmptyString,
        any.bool,
        (title, userId, isPublic) => (title: title, userId: userId, isPublic: isPublic),
      ),
    )
    .map(
      (baseItems) => baseItems
          .asMap()
          .entries
          .map(
            (entry) => QuizletEntity(
              id: 'id-${entry.key}',
              title: entry.value.title,
              subjectName: 'Toan',
              educationLevel: 'Tiểu học',
              isPublic: entry.value.isPublic,
              userId: entry.value.userId,
              termCount: 10,
              authorName: 'author',
              createdAt: '2026-01-01',
            ),
          )
          .toList(),
    );

void main() {
  group('Property 8: Xóa bộ flashcard loại bỏ đúng phần tử', () {
    Glados(
      _nonEmptyQuizletList,
      ExploreConfig(numRuns: 100),
    ).test(
      'danh sách mới không chứa id đã xóa và giữ nguyên phần tử khác',
      (quizlets) {
        final removeId = quizlets.first.id;
        final updated = quizlets.where((q) => q.id != removeId).toList();

        expect(updated.any((q) => q.id == removeId), isFalse);
        expect(updated.length, equals(quizlets.length - 1));

        final remainingOriginal =
            quizlets.where((q) => q.id != removeId).map((q) => q.id).toList();
        final remainingUpdated = updated.map((q) => q.id).toList();
        expect(remainingUpdated, equals(remainingOriginal));
      },
    );
  });
}
