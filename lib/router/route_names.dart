/// Centralized route name and path constants.
///
/// Use [RoutePaths] for `context.go(path)` calls.
/// Use [RouteNames] for `context.goNamed(name)` calls.
abstract final class RoutePaths {
  // ─── Static paths (no parameters) ───
  static const home = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const subjects = '/subjects';
  static const schedule = '/schedule';
  static const quizlet = '/quizlet';
  static const quizletCreate = '/quizlet/create';
  static const quizletEditTemplate = '/quizlet/edit/:id';
  static const quizzes = '/quizzes';
  static const examCreate = '/quizzes/create';
  static const examEditTemplate = '/quizzes/edit/:id';

  /// Đặt trong nhánh Home ([RoutePaths.home]).
  static const homeProfileSegment = 'profile';

  /// Đường dẫn đầy đủ tới profile (nested dưới `/`).
  static const profile = '/profile';
  static const pictogramGame = '/pictogram-game';
  static const pictogramPlay = '/games/pictogram/play';
  static const dictationPlay = '/games/dictation/play';
  static const vtvPlay = '/games/vtv/play';
  static const nncPlay = '/games/nhanh-nhu-chop/play';
  static const cdtnPlay = '/games/ca-dao-tuc-ngu/play';
  static const hcbPlay = '/games/hoc-cung-be/play';
  static const focusFullscreen = '/focus-fullscreen';
  static const webView = '/web-view';

  // ─── Path templates (for GoRoute definitions) ───
  static const quizletDetailTemplate = '/quizlet/:id';
  static const examDetailTemplate = '/exams/:id';
  static const examPlayTemplate = '/exams/:id/play';
  static const examResultTemplate = '/exams/:id/result';

  /// Các router dưới đây dùng [parentNavigatorKey] gốc (không nested trong shell).
  static const subjectDetailTemplate = '/subjects/:subjectId';
  static const subjectCreateCurriculumTemplate =
      '/subjects/:subjectId/create-curriculum';
  static const subjectEditCurriculumTemplate =
      '/subjects/:subjectId/edit-curriculum/:curriculumId';
  static const subjectLessonsTemplate =
      '/subjects/:subjectId/curricula/:curriculumId/lessons';
  static const subjectLessonFormTemplate =
      '/subjects/:subjectId/curricula/:curriculumId/lessons/form';
  static const subjectLessonReviewTemplate =
      '/subjects/:subjectId/curricula/:curriculumId/lessons/review/:lessonId';

  // ─── Path builders (for navigation calls) ───
  static String subjectDetail(String subjectId) => '/subjects/$subjectId';

  static String createCurriculum(String subjectId) =>
      '/subjects/$subjectId/create-curriculum';

  static String editCurriculum(String subjectId, String curriculumId) =>
      '/subjects/$subjectId/edit-curriculum/$curriculumId';

  static String quizletDetail(String id) => '/quizlet/$id';
  static String quizletEdit(String id) => '/quizlet/edit/$id';

  static String examDetail(String id) => '/exams/$id';
  static String examEdit(String id) => '/quizzes/edit/$id';

  static String examPlay(String id) => '/exams/$id/play';

  static String examResult(String id) => '/exams/$id/result';

  static String lessons(String subjectId, String curriculumId) =>
      '/subjects/$subjectId/curricula/$curriculumId/lessons';

  static String lessonForm(String subjectId, String curriculumId) =>
      '/subjects/$subjectId/curricula/$curriculumId/lessons/form';

  static String lessonReview(
    String subjectId,
    String curriculumId,
    String lessonId,
    String? subjectName,
    String? curriculumName,
    int lessonCount,
  ) =>
      '/subjects/$subjectId/curricula/$curriculumId/lessons/review/$lessonId?subjectName=$subjectName&curriculumName=$curriculumName';
}

abstract final class RouteNames {
  static const home = 'home';
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const subjects = 'subjects';
  static const subjectDetailFromSubjects = 'subjectDetailFromSubjects';
  static const createCurriculum = 'createCurriculum';
  static const editCurriculum = 'editCurriculum';
  static const schedule = 'schedule';
  static const quizlet = 'quizlet';
  static const quizletCreate = 'quizletCreate';
  static const quizletEdit = 'quizletEdit';
  static const quizletDetail = 'quizletDetail';
  static const quizzes = 'quizzes';
  static const examCreate = 'examCreate';
  static const examEdit = 'examEdit';
  static const examDetail = 'examDetail';
  static const examPlay = 'examPlay';
  static const examResult = 'examResult';
  static const profile = 'profile';
  static const pictogramGame = 'pictogramGame';
  static const pictogramPlay = 'pictogramPlay';
  static const dictationPlay = 'dictationPlay';
  static const vtvPlay = 'vtvPlay';
  static const nncPlay = 'nncPlay';
  static const cdtnPlay = 'cdtnPlay';
  static const hcbPlay = 'hcbPlay';
  static const lessons = 'lessons';
  static const lessonForm = 'lessonForm';
  static const lessonReview = 'lessonReview';
  static const focusFullscreen = 'focusFullscreen';
  static const webView = 'webView';
}
