import '../../domain/entities/curriculum_entity.dart';
import '../../domain/entities/education_level.dart';

const _unknownLabel = 'Chưa phân loại';

Map<String, List<CurriculumEntity>> groupCurriculaByLevel(
  List<CurriculumEntity> curricula,
) {
  final groups = <String, List<CurriculumEntity>>{};

  for (final c in curricula) {
    final level = EducationLevel.fromApiValue(c.educationLevel);
    final label = level?.displayLabel ?? _unknownLabel;
    groups.putIfAbsent(label, () => []).add(c);
  }

  final sortedKeys = groups.keys.toList()..sort((a, b) {
    return _sortOrder(a).compareTo(_sortOrder(b));
  });

  final result = <String, List<CurriculumEntity>>{};
  for (final key in sortedKeys) {
    result[key] = groups[key]!;
  }
  return result;
}

int _sortOrder(String label) {
  for (final level in EducationLevel.values) {
    if (level.displayLabel == label) return level.sortOrder;
  }
  // Unknown / "Chưa phân loại" goes last
  return 999;
}
