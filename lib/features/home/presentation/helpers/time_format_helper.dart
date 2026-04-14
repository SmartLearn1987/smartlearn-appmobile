/// Formats [duration] as HH:MM:SS.ms where ms is 2-digit centiseconds.
String formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  final centiseconds =
      ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds.$centiseconds';
}

/// Returns Vietnamese weekday name for [dateTime].
String vietnameseWeekday(DateTime dateTime) {
  const weekdays = {
    1: 'Thứ hai',
    2: 'Thứ ba',
    3: 'Thứ tư',
    4: 'Thứ năm',
    5: 'Thứ sáu',
    6: 'Thứ bảy',
    7: 'Chủ nhật',
  };
  return weekdays[dateTime.weekday]!;
}

/// Formats [dateTime] as dd/MM.
String formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month';
}
