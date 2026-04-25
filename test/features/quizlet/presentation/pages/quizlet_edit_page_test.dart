import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_edit_page.dart';

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

  testWidgets('QuizletEditPage shows loading state', (tester) async {
    when(() => mockBloc.state).thenReturn(const QuizletCreateState(isLoadingDetail: true));

    await tester.pumpWidget(const MaterialApp(home: QuizletEditPage(quizletId: 'q1')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('QuizletEditPage shows pre-populated form fields', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const QuizletCreateState(
        isEditMode: true,
        quizletId: 'q1',
        title: 'Quizlet title',
        description: 'Desc',
        cards: [CardFormData(term: 'a', definition: 'b')],
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: QuizletEditPage(quizletId: 'q1')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('save_quizlet_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete_quizlet_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('save_quizlet_button')), findsOneWidget);
    expect(find.byKey(const Key('delete_quizlet_button')), findsOneWidget);
  });
}
