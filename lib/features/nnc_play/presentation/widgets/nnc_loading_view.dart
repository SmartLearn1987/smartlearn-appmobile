import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class NNCLoadingView extends StatefulWidget {
  const NNCLoadingView({super.key});

  @override
  State<NNCLoadingView> createState() => _NNCLoadingViewState();
}

class _NNCLoadingViewState extends State<NNCLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(
              LucideIcons.zap,
              size: 64,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'ĐANG KẾT NỐI TIA CHỚP...',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
