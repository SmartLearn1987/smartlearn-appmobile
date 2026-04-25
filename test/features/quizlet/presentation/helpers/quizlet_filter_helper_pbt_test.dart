// Tag: Feature: quizlet-flashcard, Property 4: Lọc tổng hợp
@Tags(['quizlet-flashcard-property-4'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';

Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

Generator<String?> get _optionalString =>
    any.choose([null, '', 'Tiểu học', 'Trung học cơ sở', '  Trung học cơ sở  ']);

Generator<ViewMode> get _viewMode =>
    any.bool.map((isPersonal) => isPersonal ? ViewMode.personal : ViewMode.community);

Generator<QuizletEntity> get _quizletEntity => any.combine5(
      _nonEmptyString,
      _nonEmptyString,
      _optionalString,
      _optionalString,
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
  group('Property 4: Lọc tổng hợp', () {
    Glados(
      any.combine5(
        any.listWithLengthInRange(0, 30, _quizletEntity),
        _viewMode,
        _nonEmptyString,
        _optionalString,
        any.choose(['', 'a', 'A', 'xyz']),
        (
          List<QuizletEntity> allQuizlets,
          ViewMode viewMode,
          String currentUserId,
          String? currentUserEducationLevel,
          String searchQuery,
        ) =>
            (
          allQuizlets: allQuizlets,
          viewMode: viewMode,
          currentUserId: currentUserId,
          currentUserEducationLevel: currentUserEducationLevel,
          searchQuery: searchQuery,
        ),
      ),
      ExploreConfig(numRuns: 100),
    ).test(
      'kết quả lọc chứa đúng và đủ phần tử thỏa điều kiện',
      (sample) {
        final allQuizlets = sample.allQuizlets;
        final viewMode = sample.viewMode;
        final currentUserId = sample.currentUserId;
        final currentUserEducationLevel = sample.currentUserEducationLevel;
        final searchQuery = sample.searchQuery;
        final result = filterQuizlets(
          allQuizlets: allQuizlets,
          viewMode: viewMode,
          currentUserId: currentUserId,
          currentUserEducationLevel: currentUserEducationLevel,
          searchQuery: searchQuery,
        );

        bool satisfies(QuizletEntity quizlet) {
          final normalizedQuery = searchQuery.trim().toLowerCase();
          final titleMatches = normalizedQuery.isEmpty ||
              quizlet.title.toLowerCase().contains(normalizedQuery);
          if (!titleMatches) {
            return false;
          }

          if (viewMode == ViewMode.personal) {
            return quizlet.userId == currentUserId;
          }

          if (!quizlet.isPublic) {
            return false;
          }

          final normalizedEducationLevel =
              currentUserEducationLevel?.trim().toLowerCase();
          final hasEducationLevel = normalizedEducationLevel != null &&
              normalizedEducationLevel.isNotEmpty;

          if (!hasEducationLevel) {
            return true;
          }

          return quizlet.educationLevel?.trim().toLowerCase() ==
              normalizedEducationLevel;
        }

        final expected = allQuizlets.where(satisfies).toList();

        for (final item in result) {
          expect(
            satisfies(item),
            isTrue,
            reason: 'Found item in result that violates filter conditions: $item',
          );
        }

        expect(
          result,
          equals(expected),
          reason: 'Filtered output should include all and only valid elements',
        );
      },
    );
  });
}
