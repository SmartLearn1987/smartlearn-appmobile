import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mdLg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // ─── Avatar ───
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.displayName.isNotEmpty == true
                      ? user!.displayName[0].toUpperCase()
                      : 'U',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.primaryForeground,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.smMd),
              Text(
                user?.displayName ?? 'Người dùng',
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user?.email ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // ─── Menu items ───
              _ProfileMenuItem(
                icon: LucideIcons.user,
                label: 'Thông tin cá nhân',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProfileMenuItem(
                icon: LucideIcons.settings,
                label: 'Cài đặt',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProfileMenuItem(
                icon: LucideIcons.helpCircle,
                label: 'Trợ giúp',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.lg),
              // ─── Logout ───
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: Text(
                    'Đăng xuất',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.destructive,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    side: const BorderSide(color: AppColors.destructive),
                    shape: AppBorders.shapeSm,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(color: AppColors.border, width: AppBorders.widthThin),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.foreground),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
