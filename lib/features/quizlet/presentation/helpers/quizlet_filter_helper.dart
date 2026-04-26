import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

enum ViewMode { personal, community }

List<QuizletEntity> filterQuizlets({
  required List<QuizletEntity> allQuizlets,
  required String searchQuery,
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();

  return allQuizlets.where((quizlet) {
    return normalizedQuery.isEmpty ||
        quizlet.title.toLowerCase().contains(normalizedQuery);
  }).toList();
}
