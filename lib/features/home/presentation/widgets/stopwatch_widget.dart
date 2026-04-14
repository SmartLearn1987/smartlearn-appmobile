import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/helpers/time_format_helper.dart';

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        final cubit = context.read<FocusCubit>();
        final formatted = formatDuration(state.elapsed);
        final parts = formatted.split(':');
        final hours = parts[0];
        final minutes = parts[1];
        final secMs = parts[2];

        final monoStyle = GoogleFonts.shareTechMono(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          height: 1.2,
        );

        final colonStyle = monoStyle.copyWith(
          color: const Color(0xFF4ade80),
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
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMainButton(state, cubit),
                if (state.elapsed > Duration.zero) ...[
                  const SizedBox(width: AppSpacing.md),
                  _buildResetButton(cubit),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainButton(FocusState state, FocusCubit cubit) {
    final String label;
    final VoidCallback onPressed;

    if (state.isRunning) {
      label = 'DỪNG';
      onPressed = cubit.stopStopwatch;
    } else if (state.elapsed > Duration.zero) {
      label = 'TIẾP TỤC';
      onPressed = cubit.resumeStopwatch;
    } else {
      label = 'BẤM GIỜ';
      onPressed = cubit.startStopwatch;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        foregroundColor: Colors.white,
        shape: AppBorders.shapeSm,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.smMd,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
      child: Text(label),
    );
  }

  Widget _buildResetButton(FocusCubit cubit) {
    return OutlinedButton(
      onPressed: cubit.resetStopwatch,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.7),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        shape: AppBorders.shapeSm,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.smMd,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
      child: const Text('ĐẶT LẠI'),
    );
  }
}
