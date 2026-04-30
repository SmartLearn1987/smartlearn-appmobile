import 'package:flutter/material.dart';

class LevelConfig {
  final String value;
  final String label;
  final Color bg;
  final Color border;
  final Color text;

  LevelConfig({
    required this.value,
    required this.label,
    required this.bg,
    required this.border,
    required this.text,
  });
}

final List<LevelConfig> levels = [
  LevelConfig(
    value: "easy",
    label: "Dễ",
    bg: const Color(0xFFF0FDF4),     // green-50
    border: const Color(0xFF86EFAC), // green-300
    text: const Color(0xFF15803D),   // green-700
  ),
  LevelConfig(
    value: "medium",
    label: "Trung bình",
    bg: const Color(0xFFEFF6FF),     // blue-50
    border: const Color(0xFF93C5FD), // blue-300
    text: const Color(0xFF1D4ED8),   // blue-700
  ),
  LevelConfig(
    value: "hard",
    label: "Khó",
    bg: const Color(0xFFFFF7ED),     // orange-50
    border: const Color(0xFFFDBA74), // orange-300
    text: const Color(0xFFC2410C),   // orange-700
  ),
  LevelConfig(
    value: "extreme",
    label: "Cực khó",
    bg: const Color(0xFFFEF2F2),     // red-50
    border: const Color(0xFFFCA5A5), // red-300
    text: const Color(0xFFB91C1C),   // red-700
  ),
];