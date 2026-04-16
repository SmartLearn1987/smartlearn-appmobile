/// Formats seconds into "MM:SS" string with zero-padding.
///
/// Examples:
/// - `formatTime(125)` → `"02:05"`
/// - `formatTime(0)` → `"00:00"`
/// - `formatTime(3599)` → `"59:59"`
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
