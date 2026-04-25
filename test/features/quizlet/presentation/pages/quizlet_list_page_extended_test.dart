import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet/quizlet_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_list_page.dart';

class MockQuizletBloc extends MockBloc<QuizletEvent, QuizletState>
    implements QuizletBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockQuizletBloc mockBloc;
  late MockAuthBloc mockAuthBloc;
  final getIt = GetIt.instance;

  final testUser = UserEntity(
    id: 'current_user',
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
      userId: 'current_user',
      termCount: 20,
      authorName: 'Teacher A',
      createdAt: '2024-01-01',
    ),
  ];

  setUp(() {
    mockBloc = MockQuizletBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
    getIt.allowReassignment = true;
    getIt.registerFactory<QuizletBloc>(() => mockBloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows toggle buttons and search bar', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: testQuizlets,
        viewMode: ViewMode.community,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const QuizletListPage(),
        ),
      ),
    );

    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Cộng đồng'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tìm kiếm học phần...'), findsOneWidget);
  });

  testWidgets('shows owner badge in community mode', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: testQuizlets,
        viewMode: ViewMode.community,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const QuizletListPage(),
        ),
      ),
    );
    expect(find.text('Của bạn'), findsOneWidget);
  });

  testWidgets('shows visibility icon and menu in personal mode', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: testQuizlets,
        viewMode: ViewMode.personal,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const QuizletListPage(),
        ),
      ),
    );
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('shows create button and personal empty state', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletLoaded(
        allQuizlets: [],
        filteredQuizlets: [],
        viewMode: ViewMode.personal,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const QuizletListPage(),
        ),
      ),
    );
    expect(find.text('Bạn chưa tạo học phần nào'), findsOneWidget);
    expect(find.text('Tạo học phần đầu tiên của bạn'), findsOneWidget);
  });

  testWidgets('shows grouped headers level and subject', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: testQuizlets,
        viewMode: ViewMode.community,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const QuizletListPage(),
        ),
      ),
    );
    expect(find.text('Trung học cơ sở'), findsOneWidget);
    expect(find.text('English (1)'), findsOneWidget);
  });
}
