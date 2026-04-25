import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_create_page.dart';

class MockQuizletCreateBloc extends MockBloc<QuizletCreateEvent, QuizletCreateState>
    implements QuizletCreateBloc {}

void main() {
  late MockQuizletCreateBloc mockBloc;
  final getIt = GetIt.instance;

  setUp(() {
    mockBloc = MockQuizletCreateBloc();
    getIt.allowReassignment = true;
    getIt.registerFactory<QuizletCreateBloc>(() => mockBloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('QuizletCreatePage renders core form fields', (tester) async {
    when(() => mockBloc.state).thenReturn(const QuizletCreateState());

    await tester.pumpWidget(const MaterialApp(home: QuizletCreatePage()));

    expect(find.byKey(const Key('quizlet_title_field')), findsOneWidget);
    expect(find.byKey(const Key('quizlet_description_field')), findsOneWidget);
    expect(find.byKey(const Key('quizlet_visibility_field')), findsOneWidget);
    expect(find.byKey(const Key('quizlet_subject_field')), findsOneWidget);
    expect(find.byKey(const Key('quizlet_education_level_field')), findsOneWidget);
  });

  testWidgets('QuizletCreatePage starts with 2 empty cards', (tester) async {
    when(() => mockBloc.state).thenReturn(const QuizletCreateState());

    await tester.pumpWidget(const MaterialApp(home: QuizletCreatePage()));

    expect(find.text('Thẻ 1'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Thẻ 2'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Thẻ 2'), findsOneWidget);
  });

  testWidgets('Add card and import buttons are present', (tester) async {
    when(() => mockBloc.state).thenReturn(const QuizletCreateState());

    await tester.pumpWidget(const MaterialApp(home: QuizletCreatePage()));

    await tester.scrollUntilVisible(
      find.text('Thêm thẻ'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Thêm thẻ'), findsOneWidget);
    expect(find.text('Nhập danh sách'), findsOneWidget);
  });

  testWidgets('Submit button disabled while submitting', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletCreateState(
        isSubmitting: true,
        cards: [CardFormData.empty(), CardFormData.empty()],
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: QuizletCreatePage()));
    await tester.scrollUntilVisible(
      find.byKey(const Key('submit_quizlet_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('submit_quizlet_button')),
    );
    expect(button.onPressed, isNull);
  });
}
