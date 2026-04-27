import 'package:flutter/widgets.dart';

/// Smart Learn Spacing Tokens
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smMd = 12;
  static const double md = 16;
  static const double mdLg = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;
  static const double massive = 80;

  // ─── Common EdgeInsets ───
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingCard = EdgeInsets.all(mdLg);
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(
    horizontal: massive,
    vertical: xl,
  );
}
