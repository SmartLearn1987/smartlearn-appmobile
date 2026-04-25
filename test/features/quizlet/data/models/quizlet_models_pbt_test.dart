// Tag: Feature: quizlet-flashcard, Property 3: Serialization round-trip cho QuizletModel
@Tags(['quizlet-flashcard-property-3'])
library;

// Feature: quizlet-flashcard, Property 3: Serialization round-trip

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/data/models/quizlet_detail_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_term_model.dart';

/// Generator for non-empty alphanumeric strings.
Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

/// Generator for optional strings (nullable).
Generator<String?> get _optionalString =>
    any.choose([null, 'value_a', 'value_b', 'some text']);

/// Generator for non-negative integers.
Generator<int> get _nonNegativeInt => any.intInRange(0, 10000);

/// Generator for QuizletTermModel.
Generator<QuizletTermModel> get _quizletTermModel => any.combine5(
      _nonEmptyString,
      _nonEmptyString,
      _nonEmptyString,
      _optionalString,
      _nonNegativeInt,
      (String id, String term, String definition, String? imageUrl,
              int sortOrder) =>
          QuizletTermModel(
        id: id,
        term: term,
        definition: definition,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
      ),
    );

/// Generator for QuizletModel using combine5 + bind to handle 9 fields.
Generator<QuizletModel> get _quizletModel => any
    .combine5(
      _nonEmptyString, // id
      _nonEmptyString, // title
      _optionalString, // subjectName
      _optionalString, // educationLevel
      any.bool, // isPublic
      (String id, String title, String? subjectName, String? educationLevel,
              bool isPublic) =>
          (
        id: id,
        title: title,
        subjectName: subjectName,
        educationLevel: educationLevel,
        isPublic: isPublic,
      ),
    )
    .bind(
      (base) => any.combine4(
        _nonEmptyString, // userId
        _nonNegativeInt, // termCount
        _nonEmptyString, // authorName
        _nonEmptyString, // createdAt
        (String userId, int termCount, String authorName, String createdAt) =>
            QuizletModel(
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

/// Generator for QuizletDetailModel with a list of terms.
Generator<QuizletDetailModel> get _quizletDetailModel => any.combine5(
      _nonEmptyString, // id
      _nonEmptyString, // title
      _optionalString, // description
      _optionalString, // subjectName
      any.listWithLengthInRange(0, 5, _quizletTermModel), // terms
      (String id, String title, String? description, String? subjectName,
              List<QuizletTermModel> terms) =>
          QuizletDetailModel(
        id: id,
        title: title,
        description: description,
        subjectName: subjectName,
        terms: terms,
      ),
    );

void main() {
  // **Validates: Requirements 7.6**
  group('Property 3: Serialization round-trip cho QuizletModel', () {
    Glados(
      _quizletTermModel,
      ExploreConfig(numRuns: 100),
    ).test(
      'QuizletTermModel round-trip: fromJson(jsonDecode(jsonEncode(toJson()))) == original',
      (model) {
        final json = jsonDecode(jsonEncode(model.toJson()))
            as Map<String, dynamic>;
        final restored = QuizletTermModel.fromJson(json);

        expect(
          restored,
          equals(model),
          reason:
              'QuizletTermModel round-trip failed: '
              'original=$model, restored=$restored',
        );
      },
    );

    Glados(
      _quizletModel,
      ExploreConfig(numRuns: 100),
    ).test(
      'QuizletModel round-trip: fromJson(jsonDecode(jsonEncode(toJson()))) == original',
      (model) {
        final json = jsonDecode(jsonEncode(model.toJson()))
            as Map<String, dynamic>;
        final restored = QuizletModel.fromJson(json);

        expect(
          restored,
          equals(model),
          reason:
              'QuizletModel round-trip failed: '
              'original=$model, restored=$restored',
        );
      },
    );

    Glados(
      _quizletDetailModel,
      ExploreConfig(numRuns: 100),
    ).test(
      'QuizletDetailModel round-trip: fromJson(jsonDecode(jsonEncode(toJson()))) == original, terms preserved',
      (model) {
        final json = jsonDecode(jsonEncode(model.toJson()))
            as Map<String, dynamic>;
        final restored = QuizletDetailModel.fromJson(json);

        expect(
          restored,
          equals(model),
          reason:
              'QuizletDetailModel round-trip failed: '
              'original=$model, restored=$restored',
        );

        // Verify terms list is preserved
        expect(
          restored.terms.length,
          equals(model.terms.length),
          reason:
              'Terms count mismatch: '
              'original=${model.terms.length}, restored=${restored.terms.length}',
        );

        for (var i = 0; i < model.terms.length; i++) {
          expect(
            restored.terms[i],
            equals(model.terms[i]),
            reason: 'Term at index $i mismatch',
          );
        }
      },
    );
  });
}
