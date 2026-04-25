// Tag: Feature: quizlet-flashcard, Property 1 & 2
@Tags(['quizlet-flashcard-property-1', 'quizlet-flashcard-property-2'])
library;

// Feature: quizlet-flashcard, Property 1: FlipCard là phép nghịch đảo (involution)
// Feature: quizlet-flashcard, Property 2: Card navigation điều chỉnh index và reset flip

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:mocktail/mocktail.dart' hide any;
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_detail/quizlet_detail_bloc.dart';

class MockGetQuizletDetailUseCase extends Mock
    implements GetQuizletDetailUseCase {}

/// A fixed QuizletDetailEntity used for all property tests.
/// The property under test (FlipCard involution) only depends on `isFlipped`,
/// so the detail content is irrelevant.
final _fixedDetail = QuizletDetailEntity(
  id: 'test-id',
  title: 'Test Quizlet',
  description: 'A test quizlet',
  subjectName: 'Math',
  terms: const [
    QuizletTermEntity(
      id: 'term-1',
      term: 'Hello',
      definition: 'Xin chào',
      sortOrder: 0,
    ),
    QuizletTermEntity(
      id: 'term-2',
      term: 'Goodbye',
      definition: 'Tạm biệt',
      sortOrder: 1,
    ),
  ],
);

/// Generator for a non-empty alphanumeric string.
Generator<String> get _nonEmptyString =>
    any.letterOrDigits.map((s) => s.isEmpty ? 'a' : s);

/// Generator for a single QuizletTermEntity.
Generator<QuizletTermEntity> get _termEntity => any.combine4(
      _nonEmptyString,
      _nonEmptyString,
      _nonEmptyString,
      any.intInRange(0, 1000),
      (String id, String term, String definition, int sortOrder) =>
          QuizletTermEntity(
        id: id,
        term: term,
        definition: definition,
        sortOrder: sortOrder,
      ),
    );

/// Generator for a non-empty list of terms (1..10 items).
Generator<List<QuizletTermEntity>> get _nonEmptyTermsList =>
    any.listWithLengthInRange(1, 10, _termEntity);

/// Builds a QuizletDetailEntity from a given terms list.
QuizletDetailEntity _detailWithTerms(List<QuizletTermEntity> terms) =>
    QuizletDetailEntity(
      id: 'test-id',
      title: 'Test Quizlet',
      description: 'A test quizlet',
      subjectName: 'Math',
      terms: terms,
    );

void main() {
  // **Validates: Requirements 6.6**
  group('Property 1: FlipCard là phép nghịch đảo (involution)', () {
    Glados(any.bool, ExploreConfig(numRuns: 100)).test(
      'flip(flip(isFlipped)) == isFlipped: dispatching FlipCard twice returns to original isFlipped',
      (isFlipped) async {
        final mockGetQuizletDetail = MockGetQuizletDetailUseCase();
        final bloc = QuizletDetailBloc(mockGetQuizletDetail);

        // Seed the bloc to QuizletDetailLoaded with the random isFlipped
        bloc.emit(QuizletDetailLoaded(
          detail: _fixedDetail,
          currentIndex: 0,
          isFlipped: isFlipped,
        ));

        // Dispatch FlipCard twice
        bloc.add(const FlipCard());
        // Wait for the first event to be processed
        await Future<void>.delayed(Duration.zero);

        bloc.add(const FlipCard());
        // Wait for the second event to be processed
        await Future<void>.delayed(Duration.zero);

        // Allow stream to settle
        await Future<void>.delayed(Duration.zero);

        final finalState = bloc.state;

        expect(
          finalState,
          isA<QuizletDetailLoaded>(),
          reason: 'State should remain QuizletDetailLoaded after two FlipCard events',
        );

        final loadedState = finalState as QuizletDetailLoaded;
        expect(
          loadedState.isFlipped,
          equals(isFlipped),
          reason:
              'flip(flip($isFlipped)) should equal $isFlipped, '
              'but got ${loadedState.isFlipped}',
        );

        await bloc.close();
      },
    );
  });

  // **Validates: Requirements 5.6, 6.7**
  group('Property 2: Card navigation điều chỉnh index và reset flip', () {
    Glados(
      _nonEmptyTermsList,
      ExploreConfig(numRuns: 100),
    ).test(
      'NextCard khi currentIndex < terms.length - 1 → currentIndex + 1 và isFlipped = false',
      (terms) async {
        // Need at least 2 terms so index 0 is not the last
        if (terms.length < 2) return;

        final mockGetQuizletDetail = MockGetQuizletDetailUseCase();
        final bloc = QuizletDetailBloc(mockGetQuizletDetail);
        final detail = _detailWithTerms(terms);
        const startIndex = 0;

        // Seed with isFlipped = true to verify it resets
        bloc.emit(QuizletDetailLoaded(
          detail: detail,
          currentIndex: startIndex,
          isFlipped: true,
        ));

        bloc.add(const NextCard());
        // Wait for the stream to emit the new state
        final nextState = await bloc.stream.first;

        expect(nextState, isA<QuizletDetailLoaded>());
        final loaded = nextState as QuizletDetailLoaded;

        expect(
          loaded.currentIndex,
          equals(startIndex + 1),
          reason:
              'NextCard should increment currentIndex from $startIndex to ${startIndex + 1}',
        );
        expect(
          loaded.isFlipped,
          isFalse,
          reason: 'NextCard should reset isFlipped to false',
        );

        await bloc.close();
      },
    );

    Glados(
      _nonEmptyTermsList,
      ExploreConfig(numRuns: 100),
    ).test(
      'PreviousCard khi currentIndex > 0 → currentIndex - 1 và isFlipped = false',
      (terms) async {
        // Need at least 2 terms so we can start at index > 0
        if (terms.length < 2) return;

        final mockGetQuizletDetail = MockGetQuizletDetailUseCase();
        final bloc = QuizletDetailBloc(mockGetQuizletDetail);
        final detail = _detailWithTerms(terms);
        final startIndex = terms.length - 1; // last index, always > 0

        // Seed with isFlipped = true to verify it resets
        bloc.emit(QuizletDetailLoaded(
          detail: detail,
          currentIndex: startIndex,
          isFlipped: true,
        ));

        bloc.add(const PreviousCard());
        final nextState = await bloc.stream.first;

        expect(nextState, isA<QuizletDetailLoaded>());
        final loaded = nextState as QuizletDetailLoaded;

        expect(
          loaded.currentIndex,
          equals(startIndex - 1),
          reason:
              'PreviousCard should decrement currentIndex from $startIndex to ${startIndex - 1}',
        );
        expect(
          loaded.isFlipped,
          isFalse,
          reason: 'PreviousCard should reset isFlipped to false',
        );

        await bloc.close();
      },
    );

    Glados(
      _nonEmptyTermsList,
      ExploreConfig(numRuns: 100),
    ).test(
      'NextCard ở thẻ cuối → currentIndex không đổi',
      (terms) async {
        final mockGetQuizletDetail = MockGetQuizletDetailUseCase();
        final bloc = QuizletDetailBloc(mockGetQuizletDetail);
        final detail = _detailWithTerms(terms);
        final lastIndex = terms.length - 1;

        bloc.emit(QuizletDetailLoaded(
          detail: detail,
          currentIndex: lastIndex,
          isFlipped: false,
        ));

        // NextCard at last index should NOT emit a new state (no change).
        // We dispatch and then verify the state hasn't changed.
        bloc.add(const NextCard());
        // Give the event loop time to process
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final finalState = bloc.state;
        expect(finalState, isA<QuizletDetailLoaded>());
        final loaded = finalState as QuizletDetailLoaded;

        expect(
          loaded.currentIndex,
          equals(lastIndex),
          reason:
              'NextCard at last index ($lastIndex) should not change currentIndex',
        );

        await bloc.close();
      },
    );

    Glados(
      _nonEmptyTermsList,
      ExploreConfig(numRuns: 100),
    ).test(
      'PreviousCard ở thẻ đầu → currentIndex không đổi',
      (terms) async {
        final mockGetQuizletDetail = MockGetQuizletDetailUseCase();
        final bloc = QuizletDetailBloc(mockGetQuizletDetail);
        final detail = _detailWithTerms(terms);

        bloc.emit(QuizletDetailLoaded(
          detail: detail,
          currentIndex: 0,
          isFlipped: false,
        ));

        // PreviousCard at index 0 should NOT emit a new state (no change).
        bloc.add(const PreviousCard());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final finalState = bloc.state;
        expect(finalState, isA<QuizletDetailLoaded>());
        final loaded = finalState as QuizletDetailLoaded;

        expect(
          loaded.currentIndex,
          equals(0),
          reason:
              'PreviousCard at index 0 should not change currentIndex',
        );

        await bloc.close();
      },
    );
  });
}
