import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_learn/features/home/presentation/widgets/game_card_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/game_tab.dart';

void main() {
  setUp(() {
    // Prevent google_fonts from trying to fetch fonts at runtime in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: GameTab(),
        ),
      ),
    );
  }

  group('GameTab', () {
    testWidgets('displays "Khu Vực Trò Chơi" section title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Khu Vực Trò Chơi'), findsOneWidget);
    });

    testWidgets('displays 6 GameCardWidgets', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameCardWidget), findsNWidgets(6));
    });

    testWidgets('displays all 6 game titles', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Đuổi hình bắt chữ'), findsOneWidget);
      expect(find.text('Vua tiếng Việt'), findsOneWidget);
      expect(find.text('Chép chính tả'), findsOneWidget);
      expect(find.text('Học cùng bé'), findsOneWidget);
      expect(find.text('Ca dao tục ngữ'), findsOneWidget);
      expect(find.text('Nhanh như chớp'), findsOneWidget);
    });

    // Note: The "tapping an unavailable game shows Sắp ra mắt" test was removed
    // because all games are now available (isAvailable: true).

    testWidgets(
        'tapping "Đuổi hình bắt chữ" opens PictogramSelectionModal',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the game card for "Đuổi hình bắt chữ" (available game, index 0)
      await tester.tap(find.text('Đuổi hình bắt chữ'));
      await tester.pumpAndSettle();

      // The PictogramSelectionModal should be shown as a bottom sheet.
      // It contains "Chơi ngay" button and "Cấp độ" / "Số câu hỏi" sections.
      expect(find.text('Chơi ngay'), findsOneWidget);
      expect(find.text('Cấp độ'), findsOneWidget);
      expect(find.text('Số câu hỏi'), findsOneWidget);
      expect(find.text('Thời gian (phút)'), findsOneWidget);
    });

    testWidgets(
        'tapping "Chép chính tả" opens DictationSelectionModal',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the game card for "Chép chính tả" (available game, index 2)
      await tester.tap(find.text('Chép chính tả'));
      await tester.pumpAndSettle();

      // The DictationSelectionModal should be shown as a bottom sheet.
      // It contains "Chơi ngay" button and "Ngôn ngữ" section.
      expect(find.text('Chơi ngay'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
    });
  });
}
