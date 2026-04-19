import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/home/presentation/widgets/home_category_tabs.dart';

void main() {
  Widget buildSubject({
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HomeCategoryTabs(
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('HomeCategoryTabs', () {
    testWidgets('displays 3 tabs with correct labels', (tester) async {
      await tester.pumpWidget(
        buildSubject(selectedIndex: 0, onChanged: (_) {}),
      );

      expect(find.text('Sổ tay môn học'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Chuyên tâm'), findsOneWidget);
    });

    testWidgets('default selection highlights first tab', (tester) async {
      await tester.pumpWidget(
        buildSubject(selectedIndex: 0, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      // The first tab's AnimatedContainer should have the primary color background
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // First tab should be selected (primary color)
      final firstContainer = animatedContainers.elementAt(0);
      final firstDecoration = firstContainer.decoration as BoxDecoration?;
      expect(firstDecoration?.color, const Color(0xFF2D9B63));

      // Second tab should be unselected (transparent)
      final secondContainer = animatedContainers.elementAt(1);
      final secondDecoration = secondContainer.decoration as BoxDecoration?;
      expect(secondDecoration?.color, Colors.transparent);

      // Third tab should be unselected (transparent)
      final thirdContainer = animatedContainers.elementAt(2);
      final thirdDecoration = thirdContainer.decoration as BoxDecoration?;
      expect(thirdDecoration?.color, Colors.transparent);
    });

    testWidgets('tapping a tab calls onChanged with correct index',
        (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildSubject(
          selectedIndex: 0,
          onChanged: (index) => tappedIndex = index,
        ),
      );

      // Tap the "Game" tab (index 1)
      await tester.tap(find.text('Game'));
      expect(tappedIndex, 1);

      // Tap the "Chuyên tâm" tab (index 2)
      await tester.tap(find.text('Chuyên tâm'));
      expect(tappedIndex, 2);

      // Tap the "Sổ tay môn học" tab (index 0)
      await tester.tap(find.text('Sổ tay môn học'));
      expect(tappedIndex, 0);
    });

    testWidgets('selecting index 2 highlights third tab', (tester) async {
      await tester.pumpWidget(
        buildSubject(selectedIndex: 2, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // First tab should be unselected
      final firstContainer = animatedContainers.elementAt(0);
      final firstDecoration = firstContainer.decoration as BoxDecoration?;
      expect(firstDecoration?.color, Colors.transparent);

      // Third tab should be selected
      final thirdContainer = animatedContainers.elementAt(2);
      final thirdDecoration = thirdContainer.decoration as BoxDecoration?;
      expect(thirdDecoration?.color, const Color(0xFF2D9B63));
    });
  });
}
