import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/helpers/time_format_helper.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  static const _colonColor = Color(0xFF4ade80);

  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _colonVisible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) {
        final now = DateTime.now();
        final shouldToggle =
            (now.millisecond ~/ 500) != (_now.millisecond ~/ 500);
        setState(() {
          _now = now;
          if (shouldToggle) _colonVisible = !_colonVisible;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      hours: _now.hour,
      minutes: _now.minute,
      seconds: _now.second,
      milliseconds: _now.millisecond,
    );
    final formatted = formatDuration(duration);
    // formatted = "HH:MM:SS.ms"
    final parts = formatted.split(':');
    final hours = parts[0];
    final minutes = parts[1];
    final secMs = parts[2]; // "SS.ms"

    final monoStyle = GoogleFonts.shareTechMono(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      height: 1.2,
    );

    final colonStyle = monoStyle.copyWith(
      color: _colonVisible ? _colonColor : Colors.transparent,
    );

    final msStyle = GoogleFonts.shareTechMono(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.6),
      height: 1.2,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(hours, style: monoStyle),
            Text(':', style: colonStyle),
            Text(minutes, style: monoStyle),
            Text(':', style: colonStyle),
            Text(secMs.split('.')[0], style: monoStyle),
            Text('.${secMs.split('.')[1]}', style: msStyle),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${vietnameseWeekday(_now)}, ${formatDate(_now)}',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
