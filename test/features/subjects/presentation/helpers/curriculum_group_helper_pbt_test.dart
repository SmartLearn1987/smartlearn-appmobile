// Tag: Feature: subjects, Property 2: Curriculum grouping and sorting by education level
@Tags(['subjects-property-2'])
library;

// Feature: subjects, Property 2: Curriculum grouping and sorting by education level

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/entities/education_level.dart';
import 'package:smart_learn/features/subjects/presentation/helpers/curriculum_group_helper.dart';

const _levelApiValues = ['primary', 'secondary', 'high_school', 'university', 'other', null];

const _expectedOrder = [
  '🏫 Tiểu học',
  '🏫 Trung học cơ sở',
  '🏫 Trung học Phổ Thông',
  '🎓 Đại Học / Cao Đẳng',
  '📝 Luyện thi chứng chỉ',
  'Chưa phân loại',
];

CurriculumEntity _makeCurriculum(int id, int levelIdx) {
  final apiValue = _levelApiValues[levelIdx % _levelApiValues.length];
  return CurriculumEntity(
    id: 'cur_$id',
    subjectId: 'sub_0',
    name: 'Curriculum $id',
    educationLevel: apiValue,
    isPublic: true,
    createdBy: 'user_0',
    lessonCount: 0,
  );
}

void main() {
  // **Validates: Requirements 5.3, 5.4**
  group('Property 2: Curriculum grouping and sorting by education level', () {
    Glados(any.listWithLengthInRange(0, 30, any.intInRange(0, 5))).test(
      'grouping preserves all items, groups share same level, and groups are sorted',
      (levelIndices) {
        final curricula = levelIndices
            .asMap()
            .entries
            .map((e) => _makeCurriculum(e.key, e.value))
            .toList();

        final grouped = groupCurriculaByLevel(curricula);

        // (a) Total count across all groups equals input count
        final totalInGroups =
            grouped.values.fold<int>(0, (sum, list) => sum + list.length);
        expect(
          totalInGroups,
          equals(curricula.length),
          reason:
              'Total items in groups ($totalInGroups) != input count (${curricula.length})',
        );

        // (b) Every curriculum in a group shares the same education level label
        for (final entry in grouped.entries) {
          final label = entry.key;
          for (final c in entry.value) {
            final level = EducationLevel.fromApiValue(c.educationLevel);
            final expectedLabel = level?.displayLabel ?? 'Chưa phân loại';
            expect(
              expectedLabel,
              equals(label),
              reason:
                  'Curriculum "${c.id}" has level label "$expectedLabel" but is in group "$label"',
            );
          }
        }

        // (c) Groups are sorted in predefined order
        final keys = grouped.keys.toList();
        for (var i = 0; i < keys.length - 1; i++) {
          final idxA = _expectedOrder.indexOf(keys[i]);
          final idxB = _expectedOrder.indexOf(keys[i + 1]);
          expect(
            idxA <= idxB,
            isTrue,
            reason:
                'Group "${keys[i]}" (order $idxA) should come before "${keys[i + 1]}" (order $idxB)',
          );
        }
      },
    );
  });
}
