import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/auth/presentation/widgets/login_form_card.dart';
import 'package:smart_learn/features/auth/presentation/widgets/login_logo_header.dart';
import 'package:smart_learn/router/route_names.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            context.go(RoutePaths.home);
          case AuthError(:final message):
            AppToast.error(context, message);
          case AuthRegistrationSuccess():
            AppToast.success(context, 'Đăng ký thành công!');
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
                  LoginLogoHeader(subtitle: 'auth.login_title'.tr()),
                  const SizedBox(height: AppSpacing.lg),
                  const LoginFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
