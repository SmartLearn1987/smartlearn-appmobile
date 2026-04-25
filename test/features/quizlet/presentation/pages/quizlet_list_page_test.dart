import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet/quizlet_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_list_page.dart';

class MockQuizletBloc extends MockBloc<QuizletEvent, QuizletState>
    implements QuizletBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockQuizletBloc mockBloc;
  late MockAuthBloc mockAuthBloc;
  final getIt = GetIt.instance;

  final testUser = UserEntity(
    id: 'user_1',
    username: 'u1',
    email: 'u1@test.com',
    displayName: 'User 1',
    role: 'user',
    isActive: true,
    educationLevel: 'Trung học cơ sở',
    createdAt: DateTime(2024, 1, 1),
  );

  const testQuizlets = [
    QuizletEntity(
      id: '1',
      title: 'English Vocabulary',
      subjectName: 'English',
      educationLevel: 'Trung học cơ sở',
      isPublic: true,
      userId: 'user_1',
      termCount: 20,
      authorName: 'Teacher A',
      createdAt: '2024-01-01',
    ),
    QuizletEntity(
      id: '2',
      title: 'Math Formulas',
      subjectName: 'Math',
      educationLevel: 'Trung học Phổ Thông',
      isPublic: false,
      userId: 'user_2',
      termCount: 15,
      authorName: 'Teacher B',
      createdAt: '2024-01-02',
    ),
  ];

  setUp(() {
    mockBloc = MockQuizletBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
    // Register the mock BLoC so QuizletListPage can resolve it via getIt.
    // allowReassignment avoids errors if a previous tearDown didn't complete.
    getIt.allowReassignment = true;
    getIt.registerFactory<QuizletBloc>(() => mockBloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('QuizletListPage', () {
    testWidgets('shows CircularProgressIndicator when loading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const QuizletLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const QuizletListPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'shows list of cards with title, subjectName, termCount, authorName when loaded',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const QuizletLoaded(quizlets: testQuizlets));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const QuizletListPage(),
          ),
        ),
      );

      // First card
      expect(find.text('English Vocabulary'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('20 thuật ngữ'), findsOneWidget);
      expect(find.text('Teacher A'), findsOneWidget);

      // Second card
      expect(find.text('Math Formulas'), findsOneWidget);
      expect(find.text('Math'), findsOneWidget);
      expect(find.text('15 thuật ngữ'), findsOneWidget);
      expect(find.text('Teacher B'), findsOneWidget);
    });

    testWidgets('shows error message and retry button when error',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const QuizletError(message: 'Lỗi kết nối'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const QuizletListPage(),
          ),
        ),
      );

      expect(find.text('Lỗi kết nối'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('tapping retry button dispatches RefreshQuizlets',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const QuizletError(message: 'Lỗi kết nối'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const QuizletListPage(),
          ),
        ),
      );
      await tester.tap(find.text('Thử lại'));

      verify(() => mockBloc.add(const RefreshQuizlets())).called(1);
    });

    testWidgets('shows empty state message when loaded with empty list',
        (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const QuizletLoaded(quizlets: []));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const QuizletListPage(),
          ),
        ),
      );

      expect(find.text('Chưa có bộ flashcard nào'), findsOneWidget);
    });

    testWidgets('tapping card navigates to quizlet detail', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const QuizletLoaded(quizlets: testQuizlets));

      String? navigatedId;

      final router = GoRouter(
        initialLocation: '/quizlet',
        routes: [
          GoRoute(
            path: '/quizlet',
            builder: (context, state) => const QuizletListPage(),
          ),
          GoRoute(
            path: '/quizlet/:id',
            builder: (context, state) {
              navigatedId = state.pathParameters['id'];
              return Scaffold(
                body: Text('Detail ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first card
      await tester.tap(find.text('English Vocabulary'));
      await tester.pumpAndSettle();

      expect(navigatedId, '1');
      expect(find.text('Detail 1'), findsOneWidget);
    });
  });
}
