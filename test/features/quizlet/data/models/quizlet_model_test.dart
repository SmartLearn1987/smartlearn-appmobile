import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_detail_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_term_model.dart';

void main() {
  // ── QuizletModel.fromJson ──

  group('QuizletModel.fromJson', () {
    test('maps snake_case JSON keys to camelCase fields', () {
      final json = {
        'id': 'q1',
        'title': 'English Vocabulary',
        'subject_name': 'English',
        'education_level': 'Trung học cơ sở',
        'is_public': true,
        'user_id': 'u1',
        'term_count': 25,
        'author_name': 'Nguyen Van A',
        'created_at': '2024-01-15T10:30:00Z',
      };

      final model = QuizletModel.fromJson(json);

      expect(model.id, 'q1');
      expect(model.title, 'English Vocabulary');
      expect(model.subjectName, 'English');
      expect(model.educationLevel, 'Trung học cơ sở');
      expect(model.isPublic, true);
      expect(model.userId, 'u1');
      expect(model.termCount, 25);
      expect(model.authorName, 'Nguyen Van A');
      expect(model.createdAt, '2024-01-15T10:30:00Z');
    });

    test('handles nullable fields (subjectName, educationLevel) as null', () {
      final json = {
        'id': 'q2',
        'title': 'Math Basics',
        'subject_name': null,
        'education_level': null,
        'is_public': false,
        'user_id': 'u2',
        'term_count': 10,
        'author_name': 'Tran Thi B',
        'created_at': '2024-02-20T08:00:00Z',
      };

      final model = QuizletModel.fromJson(json);

      expect(model.subjectName, isNull);
      expect(model.educationLevel, isNull);
      expect(model.isPublic, false);
    });

    test('toJson produces snake_case keys', () {
      const model = QuizletModel(
        id: 'q1',
        title: 'Test Set',
        subjectName: 'Science',
        educationLevel: 'Tiểu học',
        isPublic: true,
        userId: 'u1',
        termCount: 5,
        authorName: 'Author',
        createdAt: '2024-01-01',
      );

      final json = model.toJson();

      expect(json['subject_name'], 'Science');
      expect(json['education_level'], 'Tiểu học');
      expect(json['is_public'], true);
      expect(json['user_id'], 'u1');
      expect(json['term_count'], 5);
      expect(json['author_name'], 'Author');
      expect(json['created_at'], '2024-01-01');
    });
  });

  // ── QuizletDetailModel.fromJson ──

  group('QuizletDetailModel.fromJson', () {
    test('parses nested terms list correctly', () {
      final json = {
        'id': 'd1',
        'title': 'Vocabulary Set',
        'description': 'A set of vocabulary words',
        'subject_name': 'English',
        'terms': [
          {
            'id': 't1',
            'term': 'Hello',
            'definition': 'Xin chào',
            'image_url': 'https://example.com/hello.png',
            'sort_order': 1,
          },
          {
            'id': 't2',
            'term': 'Goodbye',
            'definition': 'Tạm biệt',
            'image_url': null,
            'sort_order': 2,
          },
        ],
      };

      final model = QuizletDetailModel.fromJson(json);

      expect(model.id, 'd1');
      expect(model.title, 'Vocabulary Set');
      expect(model.description, 'A set of vocabulary words');
      expect(model.subjectName, 'English');
      expect(model.terms, hasLength(2));
      expect(model.terms[0].id, 't1');
      expect(model.terms[0].term, 'Hello');
      expect(model.terms[0].definition, 'Xin chào');
      expect(model.terms[0].imageUrl, 'https://example.com/hello.png');
      expect(model.terms[0].sortOrder, 1);
      expect(model.terms[1].id, 't2');
      expect(model.terms[1].imageUrl, isNull);
      expect(model.terms[1].sortOrder, 2);
    });

    test('handles empty terms list', () {
      final json = {
        'id': 'd2',
        'title': 'Empty Set',
        'description': null,
        'subject_name': null,
        'terms': <Map<String, dynamic>>[],
      };

      final model = QuizletDetailModel.fromJson(json);

      expect(model.terms, isEmpty);
      expect(model.description, isNull);
      expect(model.subjectName, isNull);
    });
  });

  // ── QuizletTermModel.fromJson ──

  group('QuizletTermModel.fromJson', () {
    test('maps snake_case JSON keys to camelCase fields', () {
      final json = {
        'id': 't1',
        'term': 'Apple',
        'definition': 'Quả táo',
        'image_url': 'https://example.com/apple.png',
        'sort_order': 3,
      };

      final model = QuizletTermModel.fromJson(json);

      expect(model.id, 't1');
      expect(model.term, 'Apple');
      expect(model.definition, 'Quả táo');
      expect(model.imageUrl, 'https://example.com/apple.png');
      expect(model.sortOrder, 3);
    });

    test('handles null imageUrl', () {
      final json = {
        'id': 't2',
        'term': 'Book',
        'definition': 'Quyển sách',
        'image_url': null,
        'sort_order': 1,
      };

      final model = QuizletTermModel.fromJson(json);

      expect(model.imageUrl, isNull);
    });
  });
}
