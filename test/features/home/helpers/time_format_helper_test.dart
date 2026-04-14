// Feature: home, Property 1: Duration formatting round-trip consistency
// Feature: home, Property 2: Vietnamese weekday mapping correctness

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/home/presentation/helpers/time_format_helper.dart';

void main() {
  // **Validates: Requirements 9.1, 10.1, 11.1**
  group('Property 1: Duration formatting round-trip consistency', () {
    Glados(any.intInRange(0, 86400000)).test(
      'formatted duration matches pattern and round-trips correctly',
      (ms) {
        final duration = Duration(milliseconds: ms);
        final formatted = formatDuration(duration);

        // Verify pattern HH:MM:SS.CC
        expect(
          RegExp(r'^\d{2}:\d{2}:\d{2}\.\d{2}$').hasMatch(formatted),
          isTrue,
          reason: 'Formatted "$formatted" does not match pattern',
        );

        // Round-trip: parse back and reconstruct
        final parts = formatted.split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secParts = parts[2].split('.');
        final seconds = int.parse(secParts[0]);
        final centiseconds = int.parse(secParts[1]);

        final reconstructed = Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: centiseconds * 10,
        );

        // Truncate original to 10ms precision for comparison
        final truncatedOriginal = Duration(
          milliseconds: (duration.inMilliseconds ~/ 10) * 10,
        );

        expect(
          reconstructed,
          equals(truncatedOriginal),
          reason:
              'Round-trip failed: $ms ms -> "$formatted" -> ${reconstructed.inMilliseconds} ms (expected ${truncatedOriginal.inMilliseconds} ms)',
        );
      },
    );
  });

  // **Validates: Requirements 9.3**
  group('Property 2: Vietnamese weekday mapping correctness', () {
    const validWeekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];

    const weekdayMap = {
      1: 'Thứ hai',
      2: 'Thứ ba',
      3: 'Thứ tư',
      4: 'Thứ năm',
      5: 'Thứ sáu',
      6: 'Thứ bảy',
      7: 'Chủ nhật',
    };

    Glados(any.intInRange(0, 3650)).test(
      'returns valid Vietnamese weekday for any date offset',
      (offset) {
        final date = DateTime(2024, 1, 1).add(Duration(days: offset));
        final result = vietnameseWeekday(date);

        expect(
          validWeekdays.contains(result),
          isTrue,
          reason: 'Got "$result" which is not a valid Vietnamese weekday',
        );

        expect(
          result,
          equals(weekdayMap[date.weekday]),
          reason:
              'For weekday ${date.weekday} expected "${weekdayMap[date.weekday]}" but got "$result"',
        );
      },
    );
  });
}
