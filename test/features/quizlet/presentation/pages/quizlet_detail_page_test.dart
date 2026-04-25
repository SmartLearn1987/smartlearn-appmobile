import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_detail/quizlet_detail_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_detail_page.dart';

class MockQuizletDetailBloc
    extends MockBloc<QuizletDetailEvent, QuizletDetailState>
    implements QuizletDetailBloc {}

void main() {
  late MockQuizletDetailBloc mockBloc;
  final getIt = GetIt.instance;

  const testTerms = [
    QuizletTermEntity(
      id: 't1',
      term: 'Hello',
      definition: 'Xin chào',
      sortOrder: 0,
    ),
    QuizletTermEntity(
      id: 't2',
      term: 'Goodbye',
      definition: 'Tạm biệt',
      sortOrder: 1,
    ),
    QuizletTermEntity(
      id: 't3',
      term: 'Thank you',
      definition: 'Cảm ơn',
      imageUrl: 'https://example.com/thankyou.png',
      sortOrder: 2,
    ),
  ];

  const testDetail = QuizletDetailEntity(
    id: 'q1',
    title: 'English Basics',
    description: 'Basic English vocabulary',
    subjectName: 'English',
    terms: testTerms,
  );

  setUp(() {
    mockBloc = MockQuizletDetailBloc();
    getIt.allowReassignment = true;
    getIt.registerFactory<QuizletDetailBloc>(() => mockBloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('QuizletDetailPage', () {
    testWidgets('shows CircularProgressIndicator when loading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoading());

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows flashcard content when loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      // First term should be visible on front side
      expect(find.text('Hello'), findsOneWidget);
      // Navigation buttons should be present
      expect(find.text('Trước'), findsOneWidget);
      expect(find.text('Tiếp'), findsOneWidget);
    });

    testWidgets('shows error message and retry button when error',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const QuizletDetailError(message: 'Không thể tải dữ liệu'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );

      expect(find.text('Không thể tải dữ liệu'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('AppBar shows title when loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      // Title in AppBar
      expect(find.text('English Basics'), findsOneWidget);
    });

    testWidgets('AppBar shows back button', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('shows card index "X/Y" correctly', (tester) async {
      // At first card: "1/3"
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('shows card index "2/3" at second card', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 1,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('progress bar has correct value', (tester) async {
      // At index 0 of 3 terms: progress = 1/3
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(1 / 3, 0.01));
    });

    testWidgets('progress bar value at last card', (tester) async {
      // At index 2 of 3 terms: progress = 3/3 = 1.0
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 2,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      // Use pump() instead of pumpAndSettle() because the last term has
      // an imageUrl which causes CachedNetworkImage to keep loading.
      await tester.pump();

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(1.0, 0.01));
    });

    testWidgets('"Trước" button is disabled at first card', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      final prevButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Trước'),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('"Tiếp" button is enabled at first card', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Tiếp'),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('"Tiếp" button is disabled at last card', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 2,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pump();

      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Tiếp'),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('"Trước" button is enabled at last card', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 2,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pump();

      final prevButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Trước'),
      );
      expect(prevButton.onPressed, isNotNull);
    });

    testWidgets('tapping "Tiếp" dispatches NextCard', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 0,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tiếp'));

      verify(() => mockBloc.add(const NextCard())).called(1);
    });

    testWidgets('tapping "Trước" dispatches PreviousCard', (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletDetailLoaded(
        detail: testDetail,
        currentIndex: 1,
        isFlipped: false,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizletDetailPage(quizletId: 'q1'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trước'));

      verify(() => mockBloc.add(const PreviousCard())).called(1);
    });
  });
}
