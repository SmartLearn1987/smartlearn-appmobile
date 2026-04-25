import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/lessons/presentation/helpers/csv_flashcard_parser.dart';

void main() {
  group('parseCsvFlashcards', () {
    test('parses simple term,definition lines', () {
      const csv = 'apple,táo\nbook,sách';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(2));
      expect(result[0], {'front': 'apple', 'back': 'táo'});
      expect(result[1], {'front': 'book', 'back': 'sách'});
    });

    test('trims whitespace from terms and definitions', () {
      const csv = '  hello  ,  xin chào  \n  world  ,  thế giới  ';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(2));
      expect(result[0], {'front': 'hello', 'back': 'xin chào'});
      expect(result[1], {'front': 'world', 'back': 'thế giới'});
    });

    test('splits on first comma only', () {
      const csv = 'phrase,this is a definition, with a comma';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(1));
      expect(result[0], {
        'front': 'phrase',
        'back': 'this is a definition, with a comma',
      });
    });

    test('skips empty lines', () {
      const csv = 'apple,táo\n\n\nbook,sách\n';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(2));
    });

    test('skips lines without a comma', () {
      const csv = 'apple,táo\nno comma here\nbook,sách';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(2));
      expect(result[0], {'front': 'apple', 'back': 'táo'});
      expect(result[1], {'front': 'book', 'back': 'sách'});
    });

    test('returns empty list for empty input', () {
      final result = parseCsvFlashcards('');
      expect(result, isEmpty);
    });

    test('returns empty list for whitespace-only input', () {
      final result = parseCsvFlashcards('   \n  \n  ');
      expect(result, isEmpty);
    });

    test('handles line with comma but both sides empty after trim', () {
      const csv = ' , ';
      final result = parseCsvFlashcards(csv);

      // Both front and back are empty after trim → skipped
      expect(result, isEmpty);
    });

    test('allows empty front with non-empty back', () {
      const csv = ',definition';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(1));
      expect(result[0], {'front': '', 'back': 'definition'});
    });

    test('allows non-empty front with empty back', () {
      const csv = 'term,';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(1));
      expect(result[0], {'front': 'term', 'back': ''});
    });

    test('handles Windows-style line endings (\\r\\n)', () {
      const csv = 'apple,táo\r\nbook,sách\r\n';
      final result = parseCsvFlashcards(csv);

      expect(result, hasLength(2));
      expect(result[0], {'front': 'apple', 'back': 'táo'});
      expect(result[1], {'front': 'book', 'back': 'sách'});
    });
  });
}
