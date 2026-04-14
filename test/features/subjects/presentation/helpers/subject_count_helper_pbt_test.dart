// Tag: Feature: subjects, Property 1: Subject curriculum count computation is correct
@Tags(['subjects-property-1'])
library;

// Feature: subjects, Property 1: Subject curriculum count computation is correct

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/presentation/helpers/subject_count_helper.dart';

SubjectEntity _makeSubject(String id) => SubjectEntity(
      id: id,
      name: 'Subject $id',
      sortOrder: 0,
      curriculumCount: 0,
    );

CurriculumEntity _makeCurriculum({
  required String id,
  required String subjectId,
  required String createdBy,
}) =>
    CurriculumEntity(
      id: id,
      subjectId: subjectId,
      name: 'Curriculum $id',
      isPublic: true,
      createdBy: createdBy,
      lessonCount: 0,
    );

void main() {
  // **Validates: Requirements 1.3, 2.2, 2.3, 5.2, 16.3**
  group('Property 1: Subject curriculum count computation is correct', () {
    Glados3(
      any.listWithLengthInRange(1, 6, any.intInRange(0, 4)),
      any.listWithLengthInRange(0, 20, any.intInRange(0, 99)),
      any.intInRange(0, 3),
    ).test(
      'userCurriculumCount matches manual filtered count for each subject',
      (subjectIdxs, curriculumSeeds, userIdx) {
        // Build unique subject IDs
        final subjectIds = subjectIdxs.map((i) => 'sub_$i').toSet().toList();
        final subjects = subjectIds.map(_makeSubject).toList();

        // Build curricula with varying subjectId and createdBy
        final curricula = curriculumSeeds.asMap().entries.map((e) {
          final seed = e.value;
          return _makeCurriculum(
            id: 'cur_${e.key}',
            subjectId: 'sub_${seed % 5}',
            createdBy: 'user_${seed % 4}',
          );
        }).toList();

        final userId = 'user_$userIdx';
        final result = computeSubjectCounts(subjects, curricula, userId);

        expect(result.length, equals(subjects.length));

        for (var i = 0; i < result.length; i++) {
          final expected = curricula
              .where(
                (c) =>
                    c.createdBy == userId &&
                    c.subjectId == subjects[i].id,
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
