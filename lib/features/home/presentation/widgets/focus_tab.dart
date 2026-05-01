import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/pages/focus_fullscreen_page.dart';
import 'package:smart_learn/features/home/presentation/widgets/clock_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/pomodoro_widget.dart';
import 'package:smart_learn/features/home/presentation/widgets/stopwatch_widget.dart';

const _subTabs = [
  (icon: LucideIcons.clock, label: 'ĐỒNG HỒ', mode: FocusMode.clock),
  (icon: LucideIcons.timer, label: 'BẤM GIỜ', mode: FocusMode.stopwatch),
  (icon: LucideIcons.hourglass, label: 'POMODORO', mode: FocusMode.pomodoro),
];

class FocusTab extends StatelessWidget {
  const FocusTab({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.mdLg),
          child: Column(
            children: [
              _SubTabs(),
              const SizedBox(height: AppSpacing.xl),
              _Content(),
              const SizedBox(height: AppSpacing.sm),
              _ExpandButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-tabs ──────────────────────────────────────────────────────────────────

class _SubTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  spacing: AppSpacing.xs,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    Text(
                      tab.label,
                      style: AppTypography.buttonSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
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
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

// ── Expand button ─────────────────────────────────────────────────────────────

class _ExpandButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _pushFullscreen(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: AppBorders.borderRadiusSm,
          ),
          child: const Icon(
            LucideIcons.maximize2,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _pushFullscreen(BuildContext context) {
    final cubit = context.read<FocusCubit>();

    // Get the render box of the card to use as animation origin
    final renderBox = context.findRenderObject() as RenderBox?;
    final cardRect = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : Rect.zero;
    final screenSize = MediaQuery.sizeOf(context);

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => FocusFullscreenPage(cubit: cubit),
        transitionsBuilder: (_, animation, __, child) {
          // Curved animation
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          // Scale: from card position/size → full screen
          final scaleX = Tween<double>(
            begin: cardRect.width / screenSize.width,
            end: 1.0,
          ).animate(curved);

          final scaleY = Tween<double>(
            begin: cardRect.height / screenSize.height,
            end: 1.0,
          ).animate(curved);

          // Translate: from card center → screen center
          final cardCenterX = cardRect.left + cardRect.width / 2;
          final cardCenterY = cardRect.top + cardRect.height / 2;
          final screenCenterX = screenSize.width / 2;
          final screenCenterY = screenSize.height / 2;

          final dx = Tween<double>(
            begin: (cardCenterX - screenCenterX) / screenSize.width,
            end: 0.0,
          ).animate(curved);

          final dy = Tween<double>(
            begin: (cardCenterY - screenCenterY) / screenSize.height,
            end: 0.0,
          ).animate(curved);

          // Border radius: from card radius → 0
          final borderRadius = Tween<double>(
            begin: AppBorders.radiusXl,
            end: 0.0,
          ).animate(curved);

          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                    dx.value * screenSize.width,
                    dy.value * screenSize.height,
                  )
                  ..scale(scaleX.value, scaleY.value),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius.value),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}
