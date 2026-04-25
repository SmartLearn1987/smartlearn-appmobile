import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';

enum ViewMode { personal, community }

List<QuizletEntity> filterQuizlets({
  required List<QuizletEntity> allQuizlets,
  required ViewMode viewMode,
  required String currentUserId,
  required String? currentUserEducationLevel,
  required String searchQuery,
}) {
  final normalizedQuery = searchQuery.trim().toLowerCase();
  final normalizedEducationLevel = currentUserEducationLevel?.trim().toLowerCase();
  final hasEducationLevel =
      normalizedEducationLevel != null && normalizedEducationLevel.isNotEmpty;

  return allQuizlets.where((quizlet) {
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

    if (!hasEducationLevel) {
      return true;
    }

    final quizletLevel = quizlet.educationLevel?.trim().toLowerCase();
    return quizletLevel == normalizedEducationLevel;
  }).toList();
}
