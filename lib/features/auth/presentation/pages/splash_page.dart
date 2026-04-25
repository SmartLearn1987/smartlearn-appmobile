import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _minDelayDone = false;
  bool _authCheckDone = false;
  AuthState? _resolvedAuthState;

  @override
  void initState() {
    super.initState();

    // Minimum 2-second splash display
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _minDelayDone = true;
      _tryNavigate();
    });

    // Check if auth already resolved (e.g. from cache)
    final currentState = context.read<AuthBloc>().state;
    if (currentState is AuthAuthenticated ||
        currentState is AuthUnauthenticated) {
      _authCheckDone = true;
      _resolvedAuthState = currentState;
    }
  }

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthAuthenticated || state is AuthUnauthenticated) {
      _authCheckDone = true;
      _resolvedAuthState = state;
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    if (!_minDelayDone || !_authCheckDone || !mounted) return;

    if (_resolvedAuthState is AuthAuthenticated) {
      context.go(RoutePaths.home);
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _onAuthStateChanged(state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.brandBrownLight,
                  borderRadius: AppBorders.borderRadiusLg,
                ),
                child: const Icon(
                  LucideIcons.library,
                  size: 48,
                  color: AppColors.brandBrown,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'app_title'.tr(),
                style: AppTypography.h1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
