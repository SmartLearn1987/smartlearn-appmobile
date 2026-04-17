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
import 'package:smart_learn/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:smart_learn/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:smart_learn/router/route_names.dart';

class ForgotPasswordFormCard extends StatefulWidget {
  const ForgotPasswordFormCard({super.key});

  @override
  State<ForgotPasswordFormCard> createState() =>
      _ForgotPasswordFormCardState();
}

class _ForgotPasswordFormCardState extends State<ForgotPasswordFormCard> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgotPasswordCubit>().forgotPassword(
            _emailController.text.trim(),
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
              controller: _emailController,
              label: 'auth.forgot_password_email_label'.tr(),
              hintText: 'auth.forgot_password_email_hint'.tr(),
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.email,
            ),
            const SizedBox(height: AppSpacing.mdLg),

            // ─── Submit button ───
            BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
              buildWhen: (previous, current) =>
                  current is ForgotPasswordLoading ||
                  previous is ForgotPasswordLoading,
              builder: (context, state) {
                final isLoading = state is ForgotPasswordLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _onSubmitPressed,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryForeground,
                            ),
                          )
                        : const Icon(LucideIcons.arrowRight, size: 18),
                    label: Text(
                      'auth.forgot_password_submit'.tr(),
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

            // ─── Back to login link ───
            Center(
              child: GestureDetector(
                onTap: () => context.go(RoutePaths.login),
                child: Text(
                  'auth.forgot_password_back_to_login'.tr(),
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
                    'auth.forgot_password_register'.tr(),
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
