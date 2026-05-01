import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/widgets/clock_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/pomodoro_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/stopwatch_widget.dart';

const _gradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0b3d22), Color(0xFF1a6e41), Color(0xFF2d9b63)],
);

const _subTabs = [
  (icon: LucideIcons.clock, label: 'ĐỒNG HỒ', mode: FocusMode.clock),
  (icon: LucideIcons.timer, label: 'BẤM GIỜ', mode: FocusMode.stopwatch),
  (icon: LucideIcons.hourglass, label: 'POMODORO', mode: FocusMode.pomodoro),
];

class FocusFullscreenPage extends StatelessWidget {
  const FocusFullscreenPage({super.key, required this.cubit});

  final FocusCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          // Status bar: white icons on dark green background
          statusBarColor: Color(0xFF0b3d22),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          // Bottom nav bar: match gradient bottom color
          systemNavigationBarColor: Color(0xFF2d9b63),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(gradient: _gradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.mdLg,
                  vertical: AppSpacing.mdLg,
                ),
                child: Column(
                  children: [
                    // ── Sub-tabs ──
                    BlocBuilder<FocusCubit, FocusState>(
                      buildWhen: (prev, curr) => prev.mode != curr.mode,
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _subTabs.map((tab) {
                            final isSelected = state.mode == tab.mode;
                            return GestureDetector(
                              onTap: () => context
                                  .read<FocusCubit>()
                                  .switchMode(tab.mode),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: AppBorders.borderRadiusSm,
                                ),
                                child: Row(
                                  spacing: AppSpacing.xs,
                                  children: [
                                    Icon(
                                      tab.icon,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      tab.label,
                                      style: AppTypography.buttonSmall.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const Spacer(),

                    // ── Content ──
                    BlocBuilder<FocusCubit, FocusState>(
                      buildWhen: (prev, curr) => prev.mode != curr.mode,
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: switch (state.mode) {
                            FocusMode.clock => const ClockWidget(
                              key: ValueKey('fs_clock'),
                            ),
                            FocusMode.stopwatch => const StopwatchWidget(
                              key: ValueKey('fs_stopwatch'),
                            ),
                            FocusMode.pomodoro => const PomodoroWidget(
                              key: ValueKey('fs_pomodoro'),
                            ),
                          },
                        );
                      },
                    ),

                    const Spacer(),
                    // ── Top bar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Back / minimize button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: AppBorders.borderRadiusSm,
                            ),
                            child: const Icon(
                              LucideIcons.minimize2,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
