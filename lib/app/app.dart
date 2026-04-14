import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/config/app_flavor.dart';
import 'package:smart_learn/core/theme/app_theme.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>()..add(const AuthCheckStatusRequested()),
      child: MaterialApp.router(
        title: AppFlavorConfig.appName,
        debugShowCheckedModeBanner: !AppFlavorConfig.isProduction,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
