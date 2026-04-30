import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/widgets/app_cached_image.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/home/presentation/bloc/profile/profile_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:smart_learn/features/home/presentation/widgets/edit_profile_bottom_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          AppToast.success(context, 'Cập nhật thành công');
        } else if (state is ProfilePasswordChanged) {
          AppToast.success(context, 'Đổi mật khẩu thành công');
        } else if (state is ProfileError) {
          AppToast.error(context, state.message);
        }
      },
      builder: (context, state) {
        // Loading state
        if (state is ProfileLoading || state is ProfileInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hồ sơ')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Hồ sơ')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.mdLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.destructive,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(const LoadProfile());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: AppBorders.shapeSm,
                      ),
                      child: Text(
                        'Thử lại',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Extract user from states that carry user data
        UserEntity? user;
        if (state is ProfileLoaded) user = state.user;
        if (state is ProfileUpdating) user = state.user;
        if (state is ProfileUpdateSuccess) user = state.user;
        if (state is ProfilePasswordChanged) user = state.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Hồ sơ')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              children: [
              const SizedBox(height: AppSpacing.lg),
              // ─── Avatar ───
              _buildAvatar(user),
              const SizedBox(height: AppSpacing.smMd),
              Text(
                user.displayName,
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user.email,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // ─── Membership & Education Card ───
              _buildMembershipCard(user),
              const SizedBox(height: AppSpacing.lg),
              // ─── Menu items ───
              _ProfileMenuItem(
                icon: LucideIcons.user,
                label: 'Thông tin cá nhân',
                onTap: () {
                  EditProfileBottomSheet.show(
                    context,
                    user!,
                    context.read<ProfileBloc>(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProfileMenuItem(
                icon: LucideIcons.lock,
                label: 'Đổi mật khẩu',
                onTap: () {
                  ChangePasswordBottomSheet.show(
                    context,
                    user!,
                    context.read<ProfileBloc>(),
                  );
                },
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
                  onPressed: () => _showLogoutDialog(context),
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
          ),
        );
      },
    );
  }

  Widget _buildAvatar(UserEntity user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return AppCachedImage(
        imageUrl: user.avatarUrl!,
        width: 80,
        height: 80,
        shape: BoxShape.circle,
        errorWidget: _buildInitialAvatar(user),
      );
    }
    return _buildInitialAvatar(user);
  }

  Widget _buildInitialAvatar(UserEntity user) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : 'U',
        style: AppTypography.h2.copyWith(
          color: AppColors.primaryForeground,
        ),
      ),
    );
  }

  Widget _buildMembershipCard(UserEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin gói thành viên',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _buildInfoRow(
            'Gói thành viên',
            user.plan ?? 'Chưa cập nhật',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Ngày hết hạn',
            user.planEndDate != null
                ? _formatDate(user.planEndDate!)
                : 'Không giới hạn',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Cấp học',
            user.educationLevel ?? 'Chưa cập nhật',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: AppTypography.h4.copyWith(color: AppColors.foreground),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.foreground,
          ),
        ),
        shape: AppBorders.shapeSm,
        backgroundColor: AppColors.card,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              'Đăng xuất',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
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
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
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
