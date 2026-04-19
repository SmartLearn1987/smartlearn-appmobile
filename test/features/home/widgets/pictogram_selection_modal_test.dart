import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/domain/usecases/get_pictogram_questions.dart';
import 'package:smart_learn/features/home/presentation/widgets/pictogram_selection_modal.dart';

class MockGetPictogramQuestionsUseCase extends Mock
    implements GetPictogramQuestionsUseCase {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGetPictogramQuestionsUseCase mockUseCase;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const PictogramParams());
  });

  setUp(() {
    mockUseCase = MockGetPictogramQuestionsUseCase();
    final getIt = GetIt.instance;
    if (getIt.isRegistered<GetPictogramQuestionsUseCase>()) {
      getIt.unregister<GetPictogramQuestionsUseCase>();
    }
    getIt.registerSingleton<GetPictogramQuestionsUseCase>(mockUseCase);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<GetPictogramQuestionsUseCase>()) {
      getIt.unregister<GetPictogramQuestionsUseCase>();
    }
  });

  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  /// Renders the modal directly inside a scrollable scaffold to avoid
  /// bottom-sheet height constraints and overflow issues in tests.
  Widget buildSubject({bool withRouter = false}) {
    final content = MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PictogramSelectionModal(),
        ),
      ),
    );

    if (withRouter) {
      return InheritedGoRouter(
        goRouter: mockGoRouter,
        child: content,
      );
    }
    return content;
  }

  group('PictogramSelectionModal', () {
    testWidgets(
        'displays default values: "Trung bình" level, 10 questions, 5 minutes',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      // Title
      expect(find.text('Đuổi hình bắt chữ'), findsOneWidget);

      // Section titles
      expect(find.text('Cấp độ'), findsOneWidget);
      expect(find.text('Số câu hỏi'), findsOneWidget);
      expect(find.text('Thời gian (phút)'), findsOneWidget);

      // "Trung bình" is only in levels — should be unique
      expect(find.text('Trung bình'), findsOneWidget);

      // "10" appears in both question counts and time options — at least one
      expect(find.text('10'), findsAtLeast(1));
      // "5" appears in both question counts and time options — at least one
      expect(find.text('5'), findsAtLeast(1));
    });

    testWidgets('renders all 4 level options', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dễ'), findsOneWidget);
      expect(find.text('Trung bình'), findsOneWidget);
      expect(find.text('Khó'), findsOneWidget);
      expect(find.text('Cực khó'), findsOneWidget);
    });

    testWidgets('renders all question count options: 5, 10, 15, 20, 30',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      // 15, 20, 30 are unique to question counts
      expect(find.text('15'), findsAtLeast(1));
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      // 5 and 10 are shared with time options
      expect(find.text('5'), findsAtLeast(1));
      expect(find.text('10'), findsAtLeast(1));
    });

    testWidgets('renders all time options: 1, 2, 3, 5, 10, 15',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      // 1, 2, 3 are unique to time options
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // 5, 10, 15 are shared with question counts
      expect(find.text('5'), findsAtLeast(1));
      expect(find.text('10'), findsAtLeast(1));
      expect(find.text('15'), findsAtLeast(1));
    });

    testWidgets('"Chơi ngay" button is present', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chơi ngay'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tapping a level option changes the selection',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      // Initially "Trung bình" (index 1) is selected — accent color
      final tbContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Trung bình'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final tbDecoration = tbContainer.decoration as BoxDecoration;
      expect(tbDecoration.color, const Color(0xFF2FA3D9)); // AppColors.accent

      // Tap "Khó"
      await tester.tap(find.text('Khó'));
      await tester.pumpAndSettle();

      // "Khó" should now be selected
      final khoContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Khó'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final khoDecoration = khoContainer.decoration as BoxDecoration;
      expect(khoDecoration.color, const Color(0xFF2FA3D9));

      // "Trung bình" should now be unselected
      final tbAfter = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Trung bình'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final tbAfterDecoration = tbAfter.decoration as BoxDecoration;
      expect(tbAfterDecoration.color, const Color(0xFFF9F7F3)); // background
    });

    testWidgets(
        'tapping "Chơi ngay" calls use case with default params',
        (tester) async {
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => const Right(<PictogramEntity>[
          PictogramEntity(
            id: '1',
            imageUrl: 'https://example.com/img.png',
            answer: 'test',
            level: 'medium',
          ),
        ]),
      );
      when(() => mockGoRouter.go(any(), extra: any(named: 'extra')))
          .thenReturn(null);

      await tester.pumpWidget(buildSubject(withRouter: true));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Chơi ngay'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockUseCase(captureAny())).captured;
      expect(captured, isNotEmpty);
      final params = captured.first as PictogramParams;
      expect(params.level, 'medium');
      expect(params.limit, 10);
    });

    testWidgets('shows error snackbar when API returns failure',
        (tester) async {
      when(() => mockUseCase(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Lỗi kết nối')),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Chơi ngay'));
      await tester.pumpAndSettle();

      expect(find.text('Lỗi kết nối'), findsOneWidget);
    });

    testWidgets(
        'shows error snackbar when API returns empty question list',
        (tester) async {
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => const Right(<PictogramEntity>[]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Chơi ngay'));
      await tester.pumpAndSettle();

      expect(
        find.text('Không có câu hỏi nào cho cấp độ này'),
        findsOneWidget,
      );
    });
  });
}
