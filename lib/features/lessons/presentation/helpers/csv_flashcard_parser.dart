/// Parses CSV content into a list of flashcard maps.
///
/// Each non-empty line is treated as a single flashcard entry.
/// The line is split on the **first** comma to produce a term (front)
/// and definition (back). Both values are trimmed.
///
/// Lines that are blank after trimming, or that contain no comma,
/// are silently skipped.
///
/// Returns a list of maps with keys `front` and `back`.
List<Map<String, String>> parseCsvFlashcards(String csvContent) {
  final lines = csvContent.split('\n');
  final results = <Map<String, String>>[];

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    final commaIndex = trimmed.indexOf(',');
    if (commaIndex < 0) continue;

    final front = trimmed.substring(0, commaIndex).trim();
    final back = trimmed.substring(commaIndex + 1).trim();

    if (front.isEmpty && back.isEmpty) continue;

    results.add({'front': front, 'back': back});
  }

  return results;
}
