import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/app/di/injection.dart';
import 'package:smart_learn/core/widgets/main_shell.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/auth/presentation/pages/login_page.dart';
import 'package:smart_learn/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:smart_learn/features/auth/presentation/pages/register_page.dart';
import 'package:smart_learn/features/home/presentation/pages/home_page.dart';
import 'package:smart_learn/features/schedule/presentation/pages/schedule_page.dart';
import 'package:smart_learn/features/subjects/presentation/pages/create_curriculum_page.dart';
import 'package:smart_learn/features/subjects/presentation/pages/edit_curriculum_page.dart';
import 'package:smart_learn/features/subjects/presentation/pages/subject_detail_page.dart';
import 'package:smart_learn/features/subjects/presentation/pages/subjects_list_page.dart';
import 'package:smart_learn/features/home/presentation/pages/profile_page.dart';
import 'package:smart_learn/features/home/presentation/pages/quiz_page.dart';
import 'package:smart_learn/router/go_router_refresh_stream.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static GoRouter? _router;

  static GoRouter get router {
    return _router ??= _createRouter();
  }

  static GoRouter _createRouter() {
    final authBloc = getIt<AuthBloc>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;

        // While checking session status, don't redirect anywhere
        if (authState is AuthInitial || authState is AuthLoading) {
          return null;
        }

        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/';
        return null;
      },
      routes: [
        // ─── Auth routes (no shell) ───
        GoRoute(
          path: '/login',
          name: 'login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // ─── Game routes (fullscreen, no shell) ───
        GoRoute(
          path: '/pictogram-game',
          name: 'pictogramGame',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Đuổi hình bắt chữ')),
            body: const Center(child: Text('Pictogram Game')),
          ),
        ),
        GoRoute(
          path: '/dictation-game',
          name: 'dictationGame',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Chép chính tả')),
            body: const Center(child: Text('Dictation Game')),
          ),
        ),

        // ─── Main shell with bottom nav ───
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) =>
                  curr is AuthAuthenticated || curr is AuthUnauthenticated,
              builder: (context, authState) {
                return MainShell(
                  currentIndex: navigationShell.currentIndex,
                  onTabChanged: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  child: navigationShell,
                );
              },
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (context, state) => const HomePage(),
                  routes: [
                    GoRoute(
                      path: 'subjects/:id',
                      name: 'subjectDetail',
                      builder: (context, state) => Scaffold(
                        appBar: AppBar(title: const Text('Môn học')),
                        body: Center(
                          child: Text(
                            'Subject detail: ${state.pathParameters['id']}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/subjects',
                  name: 'subjects',
                  builder: (context, state) => const SubjectsListPage(),
                  routes: [
                    GoRoute(
                      path: ':subjectId',
                      name: 'subjectDetailFromSubjects',
                      builder: (context, state) => SubjectDetailPage(
                        subjectId: state.pathParameters['subjectId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'create-curriculum',
                          name: 'createCurriculum',
                          parentNavigatorKey: _rootNavigatorKey,
                          builder: (context, state) => CreateCurriculumPage(
                            subjectId: state.pathParameters['subjectId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'edit-curriculum/:curriculumId',
                          name: 'editCurriculum',
                          parentNavigatorKey: _rootNavigatorKey,
                          builder: (context, state) => EditCurriculumPage(
                            subjectId: state.pathParameters['subjectId']!,
                            curriculumId: state.pathParameters['curriculumId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/schedule',
                  name: 'schedule',
                  builder: (context, state) => const SchedulePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/quizlet',
                  name: 'quizlet',
                  builder: (context, state) => const QuizPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/quizzes',
                  name: 'quizzes',
                  builder: (context, state) => const QuizPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
