import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/constants/education_level.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/validators/form_validators.dart';
import 'package:smart_learn/core/widgets/app_text_field.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/router/route_names.dart';

class RegisterFormCard extends StatefulWidget {
  const RegisterFormCard({super.key});

  @override
  State<RegisterFormCard> createState() => _RegisterFormCardState();
}

class _RegisterFormCardState extends State<RegisterFormCard> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late EducationLevel _selectedEducationLevel = EducationLevel.values.first;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          educationLevel: _selectedEducationLevel.label,
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
              prefixIcon: LucideIcons.atSign,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.username,
            ),
            const SizedBox(height: AppSpacing.mdLg),
            AppTextField(
              controller: _emailController,
              label: 'auth.email'.tr(),
              hintText: 'auth.email_hint'.tr(),
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.email,
            ),
            const SizedBox(height: AppSpacing.mdLg),
            AppTextField(
              controller: _passwordController,
              label: 'auth.password'.tr(),
              hintText: 'auth.password_hint'.tr(),
              prefixIcon: LucideIcons.lock,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.password,
              suffix: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mdLg),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'auth.confirm_password'.tr(),
              hintText: 'auth.password_hint'.tr(),
              prefixIcon: LucideIcons.lock,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) =>
                  FormValidators.confirmPassword(v, _passwordController.text),
              suffix: GestureDetector(
                onTap: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                child: Icon(
                  _obscureConfirmPassword
                      ? LucideIcons.eye
                      : LucideIcons.eyeOff,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mdLg),
            _buildEducationDropdown(),
            const SizedBox(height: AppSpacing.mdLg),
            _buildRegisterButton(),
            const SizedBox(height: AppSpacing.mdLg),
            _buildLoginRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cấp học',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<EducationLevel>(
          initialValue: _selectedEducationLevel,
          decoration: InputDecoration(
            hintText: 'Chọn cấp học',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: AppSpacing.md),
              child: Icon(
                LucideIcons.graduationCap,
                size: 18,
                color: AppColors.mutedForeground,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 44,
            ),
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: AppBorders.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.input),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorders.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.input),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorders.borderRadiusSm,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: AppBorders.widthMedium,
              ),
            ),
          ),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
          items: EducationLevel.values
              .map(
                (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level.displayLabel),
                ),
              )
              .toList(),
          onChanged: (value) => value != null
              ? setState(() => _selectedEducationLevel = value)
              : null,
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => curr is AuthLoading || prev is AuthLoading,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _onRegisterPressed,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryForeground,
                    ),
                  )
                : const Icon(LucideIcons.userPlus, size: 18),
            label: Text(
              'auth.register_button'.tr(),
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
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth.has_account'.tr(),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => context.go(RoutePaths.login),
          child: Text(
            'auth.login'.tr(),
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
