// Feature: home, Property 3: Curriculum filtering and subject count computation

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/presentation/helpers/subject_count_helper.dart';

void main() {
  // **Validates: Requirements 4.2, 4.3**
  group('Property 3: Curriculum filtering and counting', () {
    Glados3(
      // Number of subjects (1..6)
      any.intInRange(1, 7),
      // Number of curricula (0..20)
      any.intInRange(0, 21),
      // Target user index (0..3) — gives us 4 possible users
      any.intInRange(0, 4),
      ExploreConfig(numRuns: 100),
    ).test(
      'userCurriculumCount equals manual count of matching curricula per subject',
      (numSubjects, numCurricula, targetUserIdx) {
        // Build unique subjects
        final subjects = List.generate(
          numSubjects,
          (i) => SubjectEntity(
            id: 'sub_$i',
            name: 'Subject $i',
            sortOrder: i,
            curriculumCount: 0,
          ),
        );

        // Build curricula with varying subjectId and userId assignments
        final curricula = List.generate(
          numCurricula,
          (i) => CurriculumEntity(
            id: 'cur_$i',
            subjectId: 'sub_${i % numSubjects}',
            name: 'Curriculum $i',
            isPublic: true,
            userId: 'user_${i % 4}',
            lessonCount: i,
          ),
        );

        final userId = 'user_$targetUserIdx';
        final result = computeSubjectCounts(subjects, curricula, userId);

        // Output list length must equal input subjects length
        expect(result.length, equals(subjects.length));

        for (var i = 0; i < result.length; i++) {
          // Manually count curricula matching both userId and subjectId
          final expectedCount = curricula
              .where(
                (c) => c.userId == userId && c.subjectId == subjects[i].id,
              )
              .length;

          expect(
            result[i].userCurriculumCount,
            equals(expectedCount),
            reason:
                'Subject "${subjects[i].id}" with userId "$userId": '
                'expected $expectedCount but got ${result[i].userCurriculumCount}',
          );

          // The subject entity in the result must match the input subject
          expect(result[i].subject, equals(subjects[i]));
        }
      },
    );
  });
}
