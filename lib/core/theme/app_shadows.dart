import 'package:flutter/material.dart';

/// Smart Learn Shadow Tokens
/// Extracted from design spec (smart-learn.pen)
abstract final class AppShadows {
  /// Card shadow: subtle elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// Elevated shadow: modals, dropdowns
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 4),
      blurRadius: 20,
    ),
  ];

  /// Tab bar shadow
  static const List<BoxShadow> tab = [
    BoxShadow(
      color: Color(0x0D2D9B63),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// Inner tab active shadow
  static const List<BoxShadow> tabActive = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
  ];
}
