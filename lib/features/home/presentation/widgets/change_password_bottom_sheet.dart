import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_learn/core/theme/theme.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/home/presentation/bloc/profile/profile_bloc.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({
    super.key,
    required this.user,
    required this.profileBloc,
  });

  final UserEntity user;
  final ProfileBloc profileBloc;

  static void show(
    BuildContext context,
    UserEntity user,
    ProfileBloc profileBloc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ChangePasswordBottomSheet(
        user: user,
        profileBloc: profileBloc,
      ),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmationController;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  void _onChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    widget.profileBloc.add(
      ChangePassword(newPassword: _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfilePasswordChanged) {
            Navigator.of(context).pop();
            AppToast.success(context, 'Đổi mật khẩu thành công');
          } else if (state is ProfileError) {
            AppToast.error(context, state.message);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.mdLg,
              AppSpacing.sm,
              AppSpacing.mdLg,
              AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Drag handle ───
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppBorders.borderRadiusFull,
                      ),
                    ),
                  ),
                  Text(
                    'Đổi mật khẩu',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ─── New password field ───
                  Text(
                    'Mật khẩu mới',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _passwordController,
                    validator: _validatePassword,
                    obscureText: _obscurePassword,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu mới',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smMd,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.mutedForeground,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // ─── Confirm password field ───
                  Text(
                    'Xác nhận mật khẩu',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _confirmationController,
                    validator: _validateConfirmation,
                    obscureText: _obscureConfirmation,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu mới',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smMd,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmation
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.mutedForeground,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmation = !_obscureConfirmation;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.input,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthThin,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: AppBorders.borderRadiusSm,
                        borderSide: const BorderSide(
                          color: AppColors.destructive,
                          width: AppBorders.widthMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // ─── Change password button ───
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        final isUpdating = state is ProfileUpdating;
                        return ElevatedButton(
                          onPressed: isUpdating ? null : _onChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                            shape: AppBorders.shapeSm,
                            textStyle: AppTypography.buttonLarge,
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Đổi mật khẩu'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
