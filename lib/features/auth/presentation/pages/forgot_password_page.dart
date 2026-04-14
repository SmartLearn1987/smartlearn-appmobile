import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:smart_learn/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:smart_learn/features/auth/presentation/widgets/forgot_password_form_card.dart';
import 'package:smart_learn/features/auth/presentation/widgets/login_logo_header.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          switch (state) {
            case ForgotPasswordSuccess():
              AppToast.success(context, 'auth.forgot_password_success'.tr());
              context.go('/login');
            case ForgotPasswordError(:final message):
              AppToast.error(context, message);
            case _:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginLogoHeader(
                      subtitle: 'auth.forgot_password_title'.tr(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const ForgotPasswordFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
