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
import 'package:smart_learn/features/dictation_play/presentation/pages/dictation_play_screen.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/presentation/pages/profile_page.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_detail_entity.dart';
import 'package:smart_learn/features/exam/presentation/pages/exam_detail_page.dart';
import 'package:smart_learn/features/exam/presentation/pages/exam_list_page.dart';
import 'package:smart_learn/features/exam/presentation/pages/exam_play_page.dart';
import 'package:smart_learn/features/exam/presentation/pages/exam_result_page.dart';
import 'package:smart_learn/features/home/domain/entities/vtv_question_entity.dart';
import 'package:smart_learn/features/home/domain/entities/nnc_question_entity.dart';
import 'package:smart_learn/features/pictogram_play/presentation/pages/pictogram_play_screen.dart';
import 'package:smart_learn/features/vtv_play/presentation/pages/vtv_play_screen.dart';
import 'package:smart_learn/features/nnc_play/presentation/pages/nnc_play_screen.dart';
import 'package:smart_learn/features/home/domain/entities/proverb_entity.dart';
import 'package:smart_learn/features/cdtn_play/presentation/pages/cdtn_play_screen.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_detail_page.dart';
import 'package:smart_learn/features/quizlet/presentation/pages/quizlet_list_page.dart';
import 'package:smart_learn/router/go_router_refresh_stream.dart';
import 'package:smart_learn/router/route_names.dart';

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
      initialLocation: RoutePaths.home,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;

        // While checking session status, don't redirect anywhere
        if (authState is AuthInitial || authState is AuthLoading) {
          return null;
        }

        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute =
            state.matchedLocation == RoutePaths.login ||
            state.matchedLocation == RoutePaths.register ||
            state.matchedLocation == RoutePaths.forgotPassword;

        if (!isAuthenticated && !isAuthRoute) return RoutePaths.login;
        if (isAuthenticated && isAuthRoute) return RoutePaths.home;
        return null;
      },
      routes: [
        // ─── Auth routes (no shell) ───
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: RouteNames.register,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: RouteNames.forgotPassword,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // ─── Game routes (fullscreen, no shell) ───
        GoRoute(
          path: RoutePaths.pictogramGame,
          name: RouteNames.pictogramGame,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Đuổi hình bắt chữ')),
            body: const Center(child: Text('Pictogram Game')),
          ),
        ),
        GoRoute(
          path: RoutePaths.pictogramPlay,
          name: RouteNames.pictogramPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) return const _RedirectToHome();
            try {
              final questions = extra['questions'] as List<PictogramEntity>;
              final timeInMinutes = extra['timeInMinutes'] as int;
              return PictogramPlayScreen(
                questions: questions,
                timeInMinutes: timeInMinutes,
              );
            } catch (_) {
              return const _RedirectToHome();
            }
          },
        ),
        GoRoute(
          path: RoutePaths.vtvPlay,
          name: RouteNames.vtvPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) return const _RedirectToHome();
            try {
              final questions =
                  extra['questions'] as List<VTVQuestionEntity>;
              final timeInMinutes = extra['timeInMinutes'] as int;
              return VTVPlayScreen(
                questions: questions,
                timeInMinutes: timeInMinutes,
              );
            } catch (_) {
              return const _RedirectToHome();
            }
          },
        ),
        GoRoute(
          path: RoutePaths.nncPlay,
          name: RouteNames.nncPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) return const _RedirectToHome();
            try {
              final questions =
                  extra['questions'] as List<NNCQuestionEntity>;
              final timeInMinutes = extra['timeInMinutes'] as int;
              return NNCPlayScreen(
                questions: questions,
                timeInMinutes: timeInMinutes,
              );
            } catch (_) {
              return const _RedirectToHome();
            }
          },
        ),
        GoRoute(
          path: RoutePaths.cdtnPlay,
          name: RouteNames.cdtnPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) return const _RedirectToHome();
            try {
              final questions =
                  extra['questions'] as List<ProverbEntity>;
              final timeInMinutes = extra['timeInMinutes'] as int;
              return CDTNPlayScreen(
                questions: questions,
                timeInMinutes: timeInMinutes,
              );
            } catch (_) {
              return const _RedirectToHome();
            }
          },
        ),
        GoRoute(
          path: RoutePaths.dictationPlay,
          name: RouteNames.dictationPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final entity = state.extra as DictationEntity?;
            if (entity == null) return const _RedirectToHome();
            return DictationPlayScreen(entity: entity);
          },
        ),
        GoRoute(
          path: RoutePaths.quizletDetailTemplate,
          name: RouteNames.quizletDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return QuizletDetailPage(quizletId: id);
          },
        ),
        GoRoute(
          path: RoutePaths.examDetailTemplate,
          name: RouteNames.examDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ExamDetailPage(examId: id);
          },
        ),
        GoRoute(
          path: RoutePaths.examPlayTemplate,
          name: RouteNames.examPlay,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final detail = state.extra as ExamDetailEntity?;
            if (detail == null) return const _RedirectToHome();
            return ExamPlayPage(detail: detail);
          },
        ),
        GoRoute(
          path: RoutePaths.examResultTemplate,
          name: RouteNames.examResult,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final resultData = state.extra as Map<String, dynamic>?;
            if (resultData == null) return const _RedirectToHome();
            return ExamResultPage(resultData: resultData);
          },
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
                  path: RoutePaths.home,
                  name: RouteNames.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.subjects,
                  name: RouteNames.subjects,
                  builder: (context, state) => const SubjectsListPage(),
                  routes: [
                    GoRoute(
                      path: RoutePaths.subjectIdSegment,
                      name: RouteNames.subjectDetailFromSubjects,
                      builder: (context, state) {
                        final subjectId = state.pathParameters['subjectId']!;
                        return SubjectDetailPage(
                          key: ValueKey(subjectId),
                          subjectId: subjectId,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: RoutePaths.createCurriculumSegment,
                          name: RouteNames.createCurriculum,
                          builder: (context, state) => CreateCurriculumPage(
                            subjectId: state.pathParameters['subjectId']!,
                          ),
                        ),
                        GoRoute(
                          path: RoutePaths.editCurriculumSegment,
                          name: RouteNames.editCurriculum,
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
                  path: RoutePaths.schedule,
                  name: RouteNames.schedule,
                  builder: (context, state) => const SchedulePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.quizlet,
                  name: RouteNames.quizlet,
                  builder: (context, state) => const QuizletListPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.quizzes,
                  name: RouteNames.quizzes,
                  builder: (context, state) => const ExamListPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.profile,
                  name: RouteNames.profile,
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

/// A helper widget that redirects to the home route on initialization.
///
/// Used by the pictogram play route when [GoRouterState.extra] is null
/// or contains invalid data.
class _RedirectToHome extends StatefulWidget {
  const _RedirectToHome();

  @override
  State<_RedirectToHome> createState() => _RedirectToHomeState();
}

class _RedirectToHomeState extends State<_RedirectToHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(RoutePaths.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
