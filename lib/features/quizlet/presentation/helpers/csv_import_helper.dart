import 'package:equatable/equatable.dart';

class CardFormData extends Equatable {
  final String term;
  final String definition;

  const CardFormData({
    required this.term,
    required this.definition,
  });

  const CardFormData.empty()
      : term = '',
        definition = '';

  bool get hasContent => term.trim().isNotEmpty || definition.trim().isNotEmpty;

  @override
  List<Object?> get props => [term, definition];
}

List<CardFormData> parseCsvToCards(String csvContent) {
  final lines = csvContent.split(RegExp(r'\r?\n'));
  final cards = <CardFormData>[];

  for (final line in lines) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) {
      continue;
    }

    final commaIndex = trimmedLine.indexOf(',');
    if (commaIndex < 0) {
      continue;
    }

    final term = trimmedLine.substring(0, commaIndex).trim();
    final definition = trimmedLine.substring(commaIndex + 1).trim();
    cards.add(CardFormData(term: term, definition: definition));
  }

  return cards;
}
