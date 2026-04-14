// Feature: home, Property 3: Curriculum filtering and counting

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/presentation/helpers/subject_count_helper.dart';

SubjectEntity _makeSubject(int id) => SubjectEntity(
      id: 'sub_$id',
      name: 'Subject $id',
      sortOrder: id,
      curriculumCount: 0,
    );

CurriculumEntity _makeCurriculum(int id, int subjectIdx, int userIdx) =>
    CurriculumEntity(
      id: 'cur_$id',
      subjectId: 'sub_$subjectIdx',
      name: 'Curriculum $id',
      isPublic: true,
      userId: 'user_$userIdx',
      lessonCount: 0,
    );

void main() {
  // **Validates: Requirements 4.2, 4.3**
  group('Property 3: Curriculum filtering and counting', () {
    Glados2(
      any.listWithLengthInRange(1, 8, any.intInRange(0, 20)),
      any.listWithLengthInRange(0, 15, any.intInRange(0, 1000)),
    ).test(
      'userCurriculumCount matches manual count for each subject',
      (subjectIds, curriculumSeeds) {
        final subjects = subjectIds.map(_makeSubject).toList();
        final curricula = curriculumSeeds
            .map((seed) => _makeCurriculum(seed, seed % 5, seed % 3))
            .toList();

        const userId = 'user_1';
        final result = computeSubjectCounts(subjects, curricula, userId);

        expect(result.length, equals(subjects.length));

        for (var i = 0; i < result.length; i++) {
          final expected = curricula
              .where(
                (c) => c.userId == userId && c.subjectId == subjects[i].id,
              )
              .length;

          expect(
            result[i].userCurriculumCount,
            equals(expected),
            reason:
                'Subject "${subjects[i].id}": expected $expected but got ${result[i].userCurriculumCount}',
          );

          expect(result[i].subject, equals(subjects[i]));
        }
      },
    );
  });
}
