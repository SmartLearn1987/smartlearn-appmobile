import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';

QuizletEntity _quizlet({
  required String id,
  required String title,
  required String userId,
  required bool isPublic,
  String? educationLevel,
}) {
  return QuizletEntity(
    id: id,
    title: title,
    subjectName: 'Toan',
    educationLevel: educationLevel,
    isPublic: isPublic,
    userId: userId,
    termCount: 10,
    authorName: 'author',
    createdAt: '2026-01-01',
  );
}

void main() {
  final allQuizlets = [
    _quizlet(
      id: '1',
      title: 'Toan 7',
      userId: 'u1',
      isPublic: true,
      educationLevel: 'Trung học cơ sở',
    ),
    _quizlet(
      id: '2',
      title: 'Anh van 6',
      userId: 'u2',
      isPublic: true,
      educationLevel: 'Tiểu học',
    ),
    _quizlet(
      id: '3',
      title: 'Ly 8',
      userId: 'u1',
      isPublic: false,
      educationLevel: 'Trung học cơ sở',
    ),
  ];

  group('filterQuizlets', () {
    test('personal mode filters by current user id', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.personal,
        currentUserId: 'u1',
        currentUserEducationLevel: 'Tiểu học',
        searchQuery: '',
      );

      expect(result.map((q) => q.id).toList(), ['1', '3']);
    });

    test('community mode filters only public quizlets', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.community,
        currentUserId: 'u1',
        currentUserEducationLevel: null,
        searchQuery: '',
      );

      expect(result.map((q) => q.id).toList(), ['1', '2']);
    });

    test('community mode without education level sees all public levels', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.community,
        currentUserId: 'u1',
        currentUserEducationLevel: null,
        searchQuery: '',
      );

      expect(result.map((q) => q.id).toList(), ['1', '2']);
    });

    test('community mode with education level only sees matching public level', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.community,
        currentUserId: 'u1',
        currentUserEducationLevel: '  trung học cơ sở  ',
        searchQuery: '',
      );

      expect(result.map((q) => q.id).toList(), ['1']);
    });

    test('community mode with empty education level sees all public quizlets', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.community,
        currentUserId: 'u1',
        currentUserEducationLevel: '',
        searchQuery: '',
      );

      expect(result.map((q) => q.id).toList(), ['1', '2']);
    });

    test('search is case-insensitive and combined with mode filters', () {
      final result = filterQuizlets(
        allQuizlets: allQuizlets,
        viewMode: ViewMode.community,
        currentUserId: 'u1',
        currentUserEducationLevel: null,
        searchQuery: 'ANH VAN',
      );

      expect(result.map((q) => q.id).toList(), ['2']);
    });
  });
}
