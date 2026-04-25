import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';

void main() {
  group('parseCsvToCards', () {
    test('parses valid csv lines into card data', () {
      final csv = 'Hello,xin chao\nGoodbye,tam biet';

      final result = parseCsvToCards(csv);

      expect(
        result,
        const [
          CardFormData(term: 'Hello', definition: 'xin chao'),
          CardFormData(term: 'Goodbye', definition: 'tam biet'),
        ],
      );
    });

    test('ignores empty lines', () {
      final csv = '\nHello,xin chao\n   \nGoodbye,tam biet\n';

      final result = parseCsvToCards(csv);

      expect(result.length, 2);
    });

    test('handles comma in definition by splitting only at first comma', () {
      final csv = 'term,definition,with comma';

      final result = parseCsvToCards(csv);

      expect(
        result,
        const [CardFormData(term: 'term', definition: 'definition,with comma')],
      );
    });

    test('ignores lines without a comma', () {
      final csv = 'invalid line\nvalid,definition';

      final result = parseCsvToCards(csv);

      expect(
        result,
        const [CardFormData(term: 'valid', definition: 'definition')],
      );
    });
  });
}
