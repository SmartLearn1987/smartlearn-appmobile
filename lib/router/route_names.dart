/// Centralized route name and path constants.
///
/// Use [RoutePaths] for `context.go(path)` calls.
/// Use [RouteNames] for `context.goNamed(name)` calls.
abstract final class RoutePaths {
  // ─── Static paths (no parameters) ───
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const subjects = '/subjects';
  static const schedule = '/schedule';
  static const quizlet = '/quizlet';
  static const quizzes = '/quizzes';
  static const profile = '/profile';
  static const pictogramGame = '/pictogram-game';
  static const pictogramPlay = '/games/pictogram/play';
  static const dictationPlay = '/games/dictation/play';

  // ─── Path templates (for GoRoute definitions) ───
  static const quizletDetailTemplate = '/quizlet/:id';
  static const examDetailTemplate = '/exams/:id';
  static const examPlayTemplate = '/exams/:id/play';
  static const examResultTemplate = '/exams/:id/result';
  // Relative segments (nested routes)
  static const subjectIdSegment = ':subjectId';
  static const createCurriculumSegment = 'create-curriculum';
  static const editCurriculumSegment = 'edit-curriculum/:curriculumId';

  // ─── Path builders (for navigation calls) ───
  static String subjectDetail(String subjectId) =>
      '/subjects/$subjectId';

  static String createCurriculum(String subjectId) =>
      '/subjects/$subjectId/create-curriculum';

  static String editCurriculum(String subjectId, String curriculumId) =>
      '/subjects/$subjectId/edit-curriculum/$curriculumId';

  static String quizletDetail(String id) => '/quizlet/$id';

  static String examDetail(String id) => '/exams/$id';

  static String examPlay(String id) => '/exams/$id/play';

  static String examResult(String id) => '/exams/$id/result';
}

abstract final class RouteNames {
  static const home = 'home';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const subjects = 'subjects';
  static const subjectDetailFromSubjects = 'subjectDetailFromSubjects';
  static const createCurriculum = 'createCurriculum';
  static const editCurriculum = 'editCurriculum';
  static const schedule = 'schedule';
  static const quizlet = 'quizlet';
  static const quizletDetail = 'quizletDetail';
  static const quizzes = 'quizzes';
  static const examDetail = 'examDetail';
  static const examPlay = 'examPlay';
  static const examResult = 'examResult';
  static const profile = 'profile';
  static const pictogramGame = 'pictogramGame';
  static const pictogramPlay = 'pictogramPlay';
  static const dictationPlay = 'dictationPlay';
}
