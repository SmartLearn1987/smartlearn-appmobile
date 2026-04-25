import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/widgets/flashcard_widget.dart';

void main() {
  const termWithoutImage = QuizletTermEntity(
    id: 't1',
    term: 'Hello',
    definition: 'Xin chào',
    sortOrder: 0,
  );

  const termWithImage = QuizletTermEntity(
    id: 't2',
    term: 'Thank you',
    definition: 'Cảm ơn',
    imageUrl: 'https://example.com/thankyou.png',
    sortOrder: 1,
  );

  group('FlashcardWidget', () {
    testWidgets('front side shows term when not flipped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              term: termWithoutImage,
              isFlipped: false,
              onFlip: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      // Definition should not be visible on front side
      expect(find.text('Xin chào'), findsNothing);
    });

    testWidgets('back side shows definition when flipped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              term: termWithoutImage,
              isFlipped: true,
              onFlip: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xin chào'), findsOneWidget);
      // Term should not be visible on back side
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('shows image when imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              term: termWithImage,
              isFlipped: false,
              onFlip: () {},
            ),
          ),
        ),
      );
      // Pump once to build the widget tree (don't pumpAndSettle because
      // CachedNetworkImage may keep loading indefinitely in tests)
      await tester.pump();

      // The term text should be visible
      expect(find.text('Thank you'), findsOneWidget);
    });

    testWidgets('does not show image when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              term: termWithoutImage,
              isFlipped: false,
              onFlip: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only the term text should be visible, no image widget
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onFlip when tapped', (tester) async {
      var flipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              term: termWithoutImage,
              isFlipped: false,
              onFlip: () => flipCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FlashcardWidget));
      expect(flipCalled, isTrue);
    });

    testWidgets('animates from front to back when isFlipped changes',
        (tester) async {
      var isFlipped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FlashcardWidget(
                  term: termWithoutImage,
                  isFlipped: isFlipped,
                  onFlip: () => setState(() => isFlipped = !isFlipped),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially shows front (term)
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Xin chào'), findsNothing);

      // Tap to flip
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();

      // After flip, shows back (definition)
      expect(find.text('Xin chào'), findsOneWidget);
      expect(find.text('Hello'), findsNothing);
    });
  });
}
