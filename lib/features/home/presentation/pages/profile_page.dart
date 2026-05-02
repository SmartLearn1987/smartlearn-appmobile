import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/constants/app_constants.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/core/widgets/app_cached_image.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/home/presentation/bloc/profile/profile_bloc.dart';
import 'package:smart_learn/features/home/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:smart_learn/features/home/presentation/widgets/delete_account_dialog.dart';
import 'package:smart_learn/features/home/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:smart_learn/router/route_names.dart';

/// Khoảng indent divider (padding trái + vòng icon + spacing).
const double _kGroupedDividerIndent = AppSpacing.md + 36 + AppSpacing.smMd;

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

class _AppInfoItem {
  const _AppInfoItem({
    required this.label,
    required this.path,
    required this.icon,
    this.iconCircleColor,
    this.iconForegroundColor,
  });

  final String label;
  final String path;
  final IconData icon;

  /// Nền vòng icon (Premium dùng amber).
  final Color? iconCircleColor;

  final Color? iconForegroundColor;

  String get fullUrl => '$kWebBaseUrl$path';
}

/// Theo cột « Chính Sách » trong [Footer.tsx].
const List<_AppInfoItem> _kChinhSachItems = [
  _AppInfoItem(
    label: 'Nâng cấp Premium',
    path: '/premium',
    icon: LucideIcons.crown,
    iconCircleColor: AppColors.amber50,
    iconForegroundColor: AppColors.amber700,
  ),
  _AppInfoItem(
    label: 'Hướng dẫn thanh toán',
    path: '/p/payment-methods',
    icon: LucideIcons.creditCard,
    iconCircleColor: AppColors.slate100,
    iconForegroundColor: AppColors.foreground,
  ),
  _AppInfoItem(
    label: 'Chính sách bảo mật',
    path: '/p/privacy-policy',
    icon: LucideIcons.shieldCheck,
    iconCircleColor: AppColors.slate100,
    iconForegroundColor: AppColors.foreground,
  ),
];

/// Theo cột « Về Smart learn » trong [Footer.tsx].
const List<_AppInfoItem> _kVeSmartLearnItems = [
  _AppInfoItem(
    label: 'Giới thiệu về chúng tôi',
    path: '/p/about-us',
    icon: LucideIcons.info,
    iconCircleColor: AppColors.slate100,
    iconForegroundColor: AppColors.foreground,
  ),
  _AppInfoItem(
    label: 'Liên hệ với chúng tôi',
    path: '/contact',
    icon: LucideIcons.mail,
    iconCircleColor: AppColors.slate100,
    iconForegroundColor: AppColors.foreground,
  ),
  _AppInfoItem(
    label: 'Các câu hỏi thường gặp',
    path: '/p/faq',
    icon: LucideIcons.helpCircle,
    iconCircleColor: AppColors.slate100,
    iconForegroundColor: AppColors.foreground,
  ),
];

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
        } else if (state is AccountDeleted) {
          AppToast.success(context, 'Tài khoản của bạn đã được xóa thành công');
        } else if (state is ProfileError) {
          AppToast.error(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _profileAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _profileAppBar(),
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

        UserEntity? user;
        if (state is ProfileLoaded) user = state.user;
        if (state is ProfileUpdating) user = state.user;
        if (state is ProfileUpdateSuccess) user = state.user;
        if (state is ProfilePasswordChanged) user = state.user;
        if (state is AccountDeleting) user = state.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _profileAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.mdLg,
              AppSpacing.sm,
              AppSpacing.mdLg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(user),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(title: 'Thông tin cá nhân'),
                const SizedBox(height: AppSpacing.smMd),
                _buildMembershipGroupedCard(user),
                const SizedBox(height: AppSpacing.md),
                _buildGroupedActionsCard(context, user),
                const SizedBox(height: AppSpacing.sm),
                _buildDeleteAccountButton(context),
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(title: 'Chính Sách'),
                const SizedBox(height: AppSpacing.smMd),
                _buildGroupedWebLinksCard(context, _kChinhSachItems),
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(title: 'Về Smart learn'),
                const SizedBox(height: AppSpacing.smMd),
                _buildGroupedWebLinksCard(context, _kVeSmartLearnItems),
                const SizedBox(height: AppSpacing.lg),
                _buildLogoutButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _profileAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'Hồ sơ',
        style: AppTypography.h4.copyWith(color: AppColors.foreground),
      ),
    );
  }

  Widget _buildHero(UserEntity user) {
    return Column(
      children: [
        _buildAvatar(user),
        const SizedBox(height: AppSpacing.md),
        Text(
          user.displayName,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(color: AppColors.foreground),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.smMd),
        _buildPlanChip(user),
      ],
    );
  }

  Widget _buildPlanChip(UserEntity user) {
    final raw = user.plan ?? '';
    final label = raw.trim().isEmpty ? 'Chưa cập nhật' : raw.trim();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: AppBorders.widthThin,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMembershipGroupedCard(UserEntity user) {
    return _GroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.smMd),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.badgePercent,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.smMd),
                Text(
                  'Gói thành viên',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _MembershipKV(label: 'Loại gói', value: user.plan ?? 'Chưa cập nhật'),
          _groupDivider(),
          _MembershipKV(
            label: 'Ngày hết hạn',
            value: user.planEndDate != null
                ? DateFormat('dd/MM/yyyy').format(user.planEndDate!.toLocal())
                : 'Không giới hạn',
          ),
          _groupDivider(),
          _MembershipKV(
            label: 'Cấp học',
            value: user.educationLevel ?? 'Chưa cập nhật',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedActionsCard(BuildContext context, UserEntity user) {
    final bloc = context.read<ProfileBloc>();
    return _GroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupedInkRow(
            icon: LucideIcons.user,
            iconCircleColor: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
            label: 'Chỉnh sửa hồ sơ',
            onTap: () {
              EditProfileBottomSheet.show(context, user, bloc);
            },
          ),
          _groupDivider(),
          _GroupedInkRow(
            icon: LucideIcons.lock,
            iconCircleColor: AppColors.accent.withValues(alpha: 0.12),
            iconColor: AppColors.accent,
            label: 'Đổi mật khẩu',
            onTap: () {
              ChangePasswordBottomSheet.show(context, user, bloc);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () => _showDeleteDialog(context),
        icon: const Icon(LucideIcons.trash2, size: 18),
        label: const Text('Xóa tài khoản'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.destructive,
          textStyle: AppTypography.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedWebLinksCard(
    BuildContext context,
    List<_AppInfoItem> items,
  ) {
    return _GroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) _groupDivider(),
            _GroupedInkRow(
              icon: items[i].icon,
              iconCircleColor: items[i].iconCircleColor ?? AppColors.slate100,
              iconColor: items[i].iconForegroundColor ?? AppColors.foreground,
              label: items[i].label,
              onTap: () => _openWebView(context, items[i]),
              isLast: i == items.length - 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _groupDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: _kGroupedDividerIndent,
      endIndent: AppSpacing.md,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(LucideIcons.logOut, size: 18),
        label: Text(
          'Đăng xuất',
          style: AppTypography.buttonLarge.copyWith(
            color: AppColors.destructive,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.destructive,
          side: const BorderSide(color: AppColors.destructive),
          shape: AppBorders.shapeSm,
          backgroundColor: AppColors.card,
        ),
      ),
    );
  }

  void _openWebView(BuildContext context, _AppInfoItem item) {
    context.pushNamed(
      RouteNames.webView,
      extra: <String, dynamic>{'url': item.fullUrl, 'title': item.label},
    );
  }

  Widget _buildAvatar(UserEntity user) {
    Widget inner;
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      inner = AppCachedImage(
        imageUrl: user.avatarUrl!,
        width: 88,
        height: 88,
        shape: BoxShape.circle,
        errorWidget: _buildInitialAvatar(user),
      );
    } else {
      inner = _buildInitialAvatar(user);
    }
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: AppShadows.card,
      ),
      child: inner,
    );
  }

  Widget _buildInitialAvatar(UserEntity user) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
        style: AppTypography.h2.copyWith(color: AppColors.primaryForeground),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    DeleteAccountDialog.show(context, profileBloc: context.read<ProfileBloc>());
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: AppTypography.h4.copyWith(color: AppColors.foreground),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.mutedForeground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Viền + bo góc + một shadow (kiểu iOS grouped list).
class _GroupedSurface extends StatelessWidget {
  const _GroupedSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppBorders.borderRadiusMd,
        child: Material(color: Colors.transparent, child: child),
      ),
    );
  }
}

class _MembershipKV extends StatelessWidget {
  const _MembershipKV({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.smMd,
        AppSpacing.md,
        isLast ? AppSpacing.md : AppSpacing.smMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedInkRow extends StatelessWidget {
  const _GroupedInkRow({
    required this.icon,
    required this.iconCircleColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconCircleColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bottom = isLast ? AppSpacing.md + 2.0 : AppSpacing.smMd;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.foreground.withValues(alpha: 0.06),
        highlightColor: AppColors.foreground.withValues(alpha: 0.04),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.smMd + 2,
            AppSpacing.md,
            bottom,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconCircleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
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
      ),
    );
  }
}
