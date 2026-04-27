import 'package:flutter/material.dart';

/// Smart Learn Color Tokens
/// Extracted from design spec (smart-learn.pen)
abstract final class AppColors {
  // ─── Core Colors ───
  static const Color background = Color(0xFFF9F7F3);
  static const Color foreground = Color(0xFF222D3F);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFEFEDE7);
  static const Color mutedForeground = Color(0xFF6A7181);
  static const Color border = Color(0xFFE3DFD8);
  static const Color input = Color(0xFFE3DFD8);

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF2D9B63);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF0943E);
  static const Color secondaryForeground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF2FA3D9);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color brandBrown = Color(0xFFC08447);

  // ─── Semantic Colors ───
  static const Color destructive = Color(0xFFE04444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2D9B63);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF0943E);
  static const Color warningForeground = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF2FA3D9);
  static const Color infoForeground = Color(0xFFFFFFFF);
  static const Color quiz = Color(0xFF9645CC);
  static const Color quizForeground = Color(0xFFFFFFFF);

  // ─── Brand with Opacity (for icon backgrounds) ───
  static const Color primaryLight = Color(0x182D9B63);
  static const Color accentLight = Color(0x182FA3D9);
  static const Color secondaryLight = Color(0x18F0943E);
  static const Color quizLight = Color(0x189645CC);
  static const Color blue600Light = Color(0x182563EB);
  static const Color brandBrownLight = Color(0x18C08447);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color gray50 = Color(0xFFF3F4F6);
}
