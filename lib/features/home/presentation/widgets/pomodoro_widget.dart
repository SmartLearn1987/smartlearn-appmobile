import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/helpers/time_format_helper.dart';

class PomodoroWidget extends StatefulWidget {
  const PomodoroWidget({super.key});

  @override
  State<PomodoroWidget> createState() => _PomodoroWidgetState();
}

class _PomodoroWidgetState extends State<PomodoroWidget> {
  late TextEditingController _minuteController;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    _minuteController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusCubit, FocusState>(
      listenWhen: (prev, curr) =>
          !prev.pomodoroCompleted && curr.pomodoroCompleted,
      listener: (context, state) {
        if (state.pomodoroCompleted && !_completionShown) {
          _completionShown = true;
          _showCompletionDialog(context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<FocusCubit>();
        final formatted = formatDuration(state.remaining);
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

        final colonStyle = monoStyle.copyWith(color: const Color(0xFF4ade80));

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
            const SizedBox(height: AppSpacing.mdLg),
            if (!state.isRunning) _buildMinuteInput(cubit),
            const SizedBox(height: AppSpacing.mdLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!state.isRunning)
                  ElevatedButton(
                    onPressed: () {
                      _completionShown = false;
                      cubit.startPomodoro();
                    },
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
                    child: const Text('BẮT ĐẦU'),
                  ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: () {
                    _completionShown = false;
                    cubit.resetPomodoro();
                  },
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
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMinuteInput(FocusCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Thời gian (phút):',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _minuteController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(fontSize: 18),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppBorders.borderRadiusSm,
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppBorders.borderRadiusSm,
                borderSide: const BorderSide(color: Color(0xFF4ade80)),
              ),
            ),
            onChanged: (value) {
              final minutes = int.tryParse(value);
              if (minutes != null && minutes >= 1) {
                cubit.setPomodoroMinutes(minutes);
              }
            },
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: AppBorders.shapeXl,
          backgroundColor: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'XUẤT SẮC!',
                  style: AppTypography.h2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'POMODORO đã hoàn thành',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: AppBorders.shapeMd,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.smMd,
                      ),
                      textStyle: AppTypography.buttonLarge,
                    ),
                    child: const Text('TIẾP TỤC'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
