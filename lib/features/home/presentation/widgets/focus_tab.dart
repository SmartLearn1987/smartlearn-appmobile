import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/widgets/clock_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/pomodoro_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/stopwatch_widget.dart';

class FocusTab extends StatelessWidget {
  const FocusTab({super.key});

  static const _subTabs = [
    (label: 'ĐỒNG HỒ', mode: FocusMode.clock),
    (label: 'BẤM GIỜ', mode: FocusMode.stopwatch),
    (label: 'POMODORO', mode: FocusMode.pomodoro),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FocusCubit(),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0b3d22), Color(0xFF1a6e41), Color(0xFF2d9b63)],
          ),
          borderRadius: AppBorders.borderRadiusXl,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.mdLg),
              child: Column(
                children: [
                  _buildSubTabs(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildContent(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            // Positioned(
            //   right: AppSpacing.smMd,
            //   bottom: AppSpacing.smMd,
            //   child: _buildFullscreenButton(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabs() {
    return BlocBuilder<FocusCubit, FocusState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _subTabs.map((tab) {
            final isSelected = state.mode == tab.mode;
            return GestureDetector(
              onTap: () => context.read<FocusCubit>().switchMode(tab.mode),
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
                child: Text(
                  tab.label,
                  style: AppTypography.buttonSmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<FocusCubit, FocusState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        return SizedBox(
          height: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (state.mode) {
              FocusMode.clock => const ClockWidget(key: ValueKey('clock')),
              FocusMode.stopwatch => const StopwatchWidget(
                key: ValueKey('stopwatch'),
              ),
              FocusMode.pomodoro => const PomodoroWidget(
                key: ValueKey('pomodoro'),
              ),
            },
          ),
        );
      },
    );
  }
}
