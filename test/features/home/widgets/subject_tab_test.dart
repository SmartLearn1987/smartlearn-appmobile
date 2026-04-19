import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/subject_tab.dart';
import 'package:smart_learn/features/subjects/presentation/models/subject_with_count.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}

void main() {
  late MockHomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<HomeBloc>.value(
          value: mockHomeBloc,
          child: const SubjectTab(),
        ),
      ),
    );
  }

  group('SubjectTab', () {
    testWidgets('shows CircularProgressIndicator when HomeLoading',
        (tester) async {
      when(() => mockHomeBloc.state).thenReturn(const HomeLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and "Thử lại" button when HomeError',
        (tester) async {
      when(() => mockHomeBloc.state)
          .thenReturn(const HomeError(message: 'Lỗi kết nối'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Lỗi kết nối'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets(
        'shows "Các môn học" title and subject grid when HomeLoaded with subjects',
        (tester) async {
      final subjects = [
        const SubjectWithCount(
          subject: SubjectEntity(
            id: 'sub_1',
            name: 'Toán học',
            sortOrder: 1,
            curriculumCount: 5,
          ),
          icon: '📐',
          description: 'Môn học',
          userCurriculumCount: 3,
        ),
        const SubjectWithCount(
          subject: SubjectEntity(
            id: 'sub_2',
            name: 'Vật lý',
            sortOrder: 2,
            curriculumCount: 2,
          ),
          icon: '⚛️',
          description: 'Môn học',
          userCurriculumCount: 1,
        ),
      ];

      when(() => mockHomeBloc.state)
          .thenReturn(HomeLoaded(subjects: subjects));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Các môn học'), findsOneWidget);
      expect(find.text('Toán học'), findsOneWidget);
      expect(find.text('Vật lý'), findsOneWidget);
    });

    testWidgets(
        'shows empty state with "Bạn chưa chọn môn học nào" and "Thiết lập môn học" button when HomeLoaded with empty list',
        (tester) async {
      when(() => mockHomeBloc.state)
          .thenReturn(const HomeLoaded(subjects: []));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Bạn chưa chọn môn học nào'), findsOneWidget);
      expect(find.text('Thiết lập môn học'), findsOneWidget);
    });
  });
}
