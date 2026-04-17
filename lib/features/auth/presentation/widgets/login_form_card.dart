import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/validators/form_validators.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/router/route_names.dart';

class LoginFormCard extends StatefulWidget {
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusXl,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
          boxShadow: AppShadows.elevated,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _usernameController,
              label: 'auth.username'.tr(),
              hintText: 'auth.username_hint'.tr(),
              prefixIcon: LucideIcons.user,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.username,
            ),
            const SizedBox(height: AppSpacing.mdLg),
            AppTextField(
              controller: _passwordController,
              label: 'auth.password'.tr(),
              hintText: 'auth.password_hint'.tr(),
              prefixIcon: LucideIcons.lock,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.password,
              suffix: GestureDetector(
                onTap: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
                child: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mdLg),

            // ─── Login button ───
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) =>
                  current is AuthLoading || previous is AuthLoading,
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _onLoginPressed,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryForeground,
                            ),
                          )
                        : const Icon(LucideIcons.logIn, size: 18),
                    label: Text(
                      'auth.login'.tr(),
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.primaryForeground,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      shape: AppBorders.shapeSm,
                      elevation: 0,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.smMd),

            // ─── Forgot password link ───
            Center(
              child: GestureDetector(
                onTap: () => context.go(RoutePaths.forgotPassword),
                child: Text(
                  'auth.forgot_password'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.mdLg),

            // ─── Register row ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'auth.no_account'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => context.go(RoutePaths.register),
                  child: Text(
                    'auth.register'.tr(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
