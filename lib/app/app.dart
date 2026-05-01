import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/theme/app_theme.dart';
import 'package:smart_learn/core/widgets/app_toast.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/subjects/presentation/bloc/subjects_list/subjects_list_bloc.dart';
import 'package:smart_learn/features/subjects/presentation/bloc/subject_detail/subject_detail_bloc.dart';
import 'package:smart_learn/router/app_router.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>()..add(const AuthCheckStatusRequested()),
        ),
        BlocProvider<HomeBloc>.value(value: getIt<HomeBloc>()),
        BlocProvider<SubjectsListBloc>.value(value: getIt<SubjectsListBloc>()),
        BlocProvider<SubjectDetailBloc>.value(
          value: getIt<SubjectDetailBloc>(),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF9F7F3),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: ToastificationWrapper(
          child: MaterialApp.router(
            title: 'Smart Learn',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: AppRouter.router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.noScaling),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: BlocListener<AuthBloc, AuthState>(
                    listenWhen: (prev, curr) =>
                        curr is AuthUnauthenticated && curr.message != null,
                    listener: (context, state) {
                      if (state is AuthUnauthenticated &&
                          state.message != null) {
                        AppToast.error(context, state.message!);
                      }
                    },
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
