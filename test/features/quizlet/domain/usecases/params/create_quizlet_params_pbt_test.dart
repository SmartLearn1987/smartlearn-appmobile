// Tag: Feature: quizlet-flashcard, Property 11: Serialization round-trip cho CreateQuizletParams
@Tags(['quizlet-flashcard-property-11'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';

Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

Generator<String?> get _optionalString =>
    any.choose([null, 'value_a', 'value_b', 'some text']);

Generator<TermParams> get _termParams => any.combine2(
      _nonEmptyString,
      _nonEmptyString,
      (String term, String definition) => TermParams(
        term: term,
        definition: definition,
      ),
    );

Generator<CreateQuizletParams> get _createQuizletParams => any.combine5(
      _nonEmptyString, // title
      _optionalString, // description
      _optionalString, // subjectId
      _optionalString, // grade
      _optionalString, // educationLevel
      (
        String title,
        String? description,
        String? subjectId,
        String? grade,
        String? educationLevel,
      ) =>
          (
        title: title,
        description: description,
        subjectId: subjectId,
        grade: grade,
        educationLevel: educationLevel,
      ),
    ).bind(
      (base) => any.combine3(
        any.bool, // isPublic
        _nonEmptyString, // createdBy
        any.listWithLengthInRange(0, 8, _termParams), // terms
        (bool isPublic, String createdBy, List<TermParams> terms) =>
            CreateQuizletParams(
          title: base.title,
          description: base.description,
          subjectId: base.subjectId,
          grade: base.grade,
          educationLevel: base.educationLevel,
          isPublic: isPublic,
          createdBy: createdBy,
          terms: terms,
        ),
      ),
    );

void main() {
  group('Property 11: Serialization round-trip cho CreateQuizletParams', () {
    Glados(
      _createQuizletParams,
      ExploreConfig(numRuns: 100),
    ).test(
      'CreateQuizletParams.fromJson(params.toJson()) == params và terms được bảo toàn',
      (params) {
        final json = jsonDecode(jsonEncode(params.toJson()))
            as Map<String, dynamic>;
        final restored = CreateQuizletParams.fromJson(json);

        expect(
          restored,
          equals(params),
          reason:
              'CreateQuizletParams round-trip failed: '
              'original=$params, restored=$restored',
        );

        expect(
          restored.terms,
          equals(params.terms),
          reason: 'Nested TermParams list should be preserved after round-trip',
        );
      },
    );
  });
}
