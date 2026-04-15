import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/features/pictogram_play/presentation/widgets/game_timer_display.dart';

void main() {
  Widget buildWidget(int remainingSeconds) {
    return MaterialApp(
      home: Scaffold(
        body: GameTimerDisplay(remainingSeconds: remainingSeconds),
      ),
    );
  }

  group('GameTimerDisplay', () {
    testWidgets('displays time in MM:SS format', (tester) async {
      await tester.pumpWidget(buildWidget(125));

      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('displays 00:00 when remainingSeconds is 0', (tester) async {
      await tester.pumpWidget(buildWidget(0));

      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('uses destructive color when remainingSeconds < 30',
        (tester) async {
      await tester.pumpWidget(buildWidget(29));

      final text = tester.widget<Text>(find.text('00:29'));
      expect(text.style?.color, AppColors.destructive);
    });

    testWidgets('uses foreground color when remainingSeconds >= 30',
        (tester) async {
      await tester.pumpWidget(buildWidget(30));

      final text = tester.widget<Text>(find.text('00:30'));
      expect(text.style?.color, AppColors.foreground);
    });

    testWidgets('uses foreground color for large remaining time',
        (tester) async {
      await tester.pumpWidget(buildWidget(300));

      final text = tester.widget<Text>(find.text('05:00'));
      expect(text.style?.color, AppColors.foreground);
    });
  });
}
