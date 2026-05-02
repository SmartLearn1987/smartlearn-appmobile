// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:flutter_tts/flutter_tts.dart' as _i50;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../core/network/auth_interceptor.dart' as _i388;
import '../../core/network/dio_client.dart' as _i571;
import '../../core/services/tts_module.dart' as _i1038;
import '../../core/services/tts_service.dart' as _i643;
import '../../core/services/tts_service_impl.dart' as _i479;
import '../../core/storage/secure_storage_module.dart' as _i1071;
import '../../core/storage/shared_preferences_module.dart' as _i205;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/datasources/auth_remote_datasource_module.dart'
    as _i674;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/change_password_usecase.dart'
    as _i788;
import '../../features/auth/domain/usecases/delete_account_usecase.dart'
    as _i914;
import '../../features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i560;
import '../../features/auth/domain/usecases/get_profile_usecase.dart' as _i568;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/update_profile_usecase.dart'
    as _i798;
import '../../features/auth/domain/usecases/upload_file_usecase.dart' as _i91;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart'
    as _i104;
import '../../features/dictation_play/presentation/bloc/dictation_play_bloc.dart'
    as _i130;
import '../../features/exam/data/datasources/exam_remote_datasource.dart'
    as _i977;
import '../../features/exam/data/repositories/exam_repository_impl.dart'
    as _i362;
import '../../features/exam/domain/repositories/exam_repository.dart' as _i413;
import '../../features/exam/domain/usecases/get_exam_detail_use_case.dart'
    as _i1072;
import '../../features/exam/domain/usecases/get_exams_use_case.dart' as _i347;
import '../../features/exam/domain/usecases/submit_exam_result_use_case.dart'
    as _i891;
import '../../features/exam/presentation/bloc/exam/exam_bloc.dart' as _i729;
import '../../features/exam/presentation/bloc/exam_detail/exam_detail_bloc.dart'
    as _i591;
import '../../features/exam/presentation/bloc/exam_play/exam_play_bloc.dart'
    as _i711;
import '../../features/home/data/datasources/home_remote_datasource.dart'
    as _i278;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/usecases/get_all_subjects.dart' as _i376;
import '../../features/home/domain/usecases/get_curricula.dart' as _i93;
import '../../features/home/domain/usecases/get_learning_categories.dart'
    as _i535;
import '../../features/home/domain/usecases/get_learning_questions.dart'
    as _i821;
import '../../features/home/domain/usecases/get_nnc_questions.dart' as _i146;
import '../../features/home/domain/usecases/get_pictogram_questions.dart'
    as _i654;
import '../../features/home/domain/usecases/get_proverb_questions.dart'
    as _i329;
import '../../features/home/domain/usecases/get_random_dictation.dart' as _i900;
import '../../features/home/domain/usecases/get_subjects.dart' as _i185;
import '../../features/home/domain/usecases/get_user_subjects.dart' as _i839;
import '../../features/home/domain/usecases/get_vtv_questions.dart' as _i182;
import '../../features/home/domain/usecases/save_user_subjects.dart' as _i541;
import '../../features/home/presentation/bloc/focus_cubit.dart' as _i128;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/home/presentation/bloc/profile/profile_bloc.dart'
    as _i124;
import '../../features/lessons/data/datasources/lessons_remote_datasource.dart'
    as _i753;
import '../../features/lessons/data/repositories/lessons_repository_impl.dart'
    as _i393;
import '../../features/lessons/domain/repositories/lessons_repository.dart'
    as _i265;
import '../../features/lessons/domain/usecases/create_lesson_use_case.dart'
    as _i200;
import '../../features/lessons/domain/usecases/delete_lesson_image_use_case.dart'
    as _i470;
import '../../features/lessons/domain/usecases/delete_lesson_use_case.dart'
    as _i896;
import '../../features/lessons/domain/usecases/get_lesson_by_id_use_case.dart'
    as _i231;
import '../../features/lessons/domain/usecases/get_lesson_images_use_case.dart'
    as _i1056;
import '../../features/lessons/domain/usecases/get_lesson_progress_use_case.dart'
    as _i75;
import '../../features/lessons/domain/usecases/get_lessons_use_case.dart'
    as _i46;
import '../../features/lessons/domain/usecases/update_lesson_progress_use_case.dart'
    as _i400;
import '../../features/lessons/domain/usecases/update_lesson_use_case.dart'
    as _i969;
import '../../features/lessons/domain/usecases/update_quiz_flashcards_use_case.dart'
    as _i721;
import '../../features/lessons/domain/usecases/upload_lesson_images_use_case.dart'
    as _i847;
import '../../features/lessons/presentation/bloc/lesson_detail/lesson_detail_bloc.dart'
    as _i367;
import '../../features/lessons/presentation/bloc/lessons_list/lessons_list_bloc.dart'
    as _i966;
import '../../features/quizlet/data/datasources/quizlet_remote_datasource.dart'
    as _i237;
import '../../features/quizlet/data/repositories/quizlet_repository_impl.dart'
    as _i364;
import '../../features/quizlet/domain/repositories/quizlet_repository.dart'
    as _i718;
import '../../features/quizlet/domain/usecases/create_quizlet_use_case.dart'
    as _i743;
import '../../features/quizlet/domain/usecases/delete_quizlet_use_case.dart'
    as _i231;
import '../../features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart'
    as _i595;
import '../../features/quizlet/domain/usecases/get_quizlets_use_case.dart'
    as _i1064;
import '../../features/quizlet/domain/usecases/update_quizlet_use_case.dart'
    as _i600;
import '../../features/quizlet/presentation/bloc/quizlet/quizlet_bloc.dart'
    as _i252;
import '../../features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart'
    as _i496;
import '../../features/quizlet/presentation/bloc/quizlet_detail/quizlet_detail_bloc.dart'
    as _i518;
import '../../features/schedule/data/datasources/schedule_local_datasource.dart'
    as _i219;
import '../../features/schedule/data/datasources/schedule_remote_datasource.dart'
    as _i115;
import '../../features/schedule/data/repositories/schedule_local_repository_impl.dart'
    as _i502;
import '../../features/schedule/data/repositories/schedule_repository_impl.dart'
    as _i688;
import '../../features/schedule/domain/repositories/schedule_local_repository.dart'
    as _i500;
import '../../features/schedule/domain/repositories/schedule_repository.dart'
    as _i736;
import '../../features/schedule/presentation/cubit/notes/notes_cubit.dart'
    as _i919;
import '../../features/schedule/presentation/cubit/tasks/tasks_cubit.dart'
    as _i543;
import '../../features/schedule/presentation/cubit/timetable/timetable_cubit.dart'
    as _i596;
import '../../features/subjects/data/datasources/subjects_remote_datasource.dart'
    as _i574;
import '../../features/subjects/data/repositories/subjects_repository_impl.dart'
    as _i962;
import '../../features/subjects/domain/repositories/subjects_repository.dart'
    as _i640;
import '../../features/subjects/domain/usecases/create_curriculum_use_case.dart'
    as _i901;
import '../../features/subjects/domain/usecases/delete_curriculum_use_case.dart'
    as _i644;
import '../../features/subjects/domain/usecases/get_curricula_by_subject_use_case.dart'
    as _i995;
import '../../features/subjects/domain/usecases/get_subject_detail_use_case.dart'
    as _i638;
import '../../features/subjects/domain/usecases/get_subjects_use_case.dart'
    as _i181;
import '../../features/subjects/domain/usecases/update_curriculum_use_case.dart'
    as _i502;
import '../../features/subjects/domain/usecases/upload_image_use_case.dart'
    as _i765;
import '../../features/subjects/presentation/bloc/curriculum_form/curriculum_form_bloc.dart'
    as _i910;
import '../../features/subjects/presentation/bloc/subject_detail/subject_detail_bloc.dart'
    as _i121;
import '../../features/subjects/presentation/bloc/subjects_list/subjects_list_bloc.dart'
    as _i900;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final ttsModule = _$TtsModule();
    final secureStorageModule = _$SecureStorageModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final dioModule = _$DioModule();
    final authRemoteModule = _$AuthRemoteModule();
    gh.factory<_i128.FocusCubit>(() => _i128.FocusCubit());
    gh.lazySingleton<_i50.FlutterTts>(() => ttsModule.flutterTts);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.refreshDio(),
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i992.AuthLocalDatasource>(
      () => _i992.AuthLocalDatasource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i219.ScheduleLocalDatasource>(
      () => _i219.ScheduleLocalDatasource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i500.ScheduleLocalRepository>(
      () => _i502.ScheduleLocalRepositoryImpl(
        gh<_i219.ScheduleLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i643.TtsService>(
      () => _i479.TtsServiceImpl(gh<_i50.FlutterTts>()),
    );
    gh.factory<_i388.AuthInterceptor>(
      () => _i388.AuthInterceptor(
        gh<_i992.AuthLocalDatasource>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i388.AuthInterceptor>()),
    );
    gh.lazySingleton<_i161.AuthRemoteDatasource>(
      () => authRemoteModule.authRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i977.ExamRemoteDatasource>(
      () => _i977.ExamRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i278.HomeRemoteDatasource>(
      () => _i278.HomeRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i753.LessonsRemoteDatasource>(
      () => _i753.LessonsRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i237.QuizletRemoteDatasource>(
      () => _i237.QuizletRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i115.ScheduleRemoteDatasource>(
      () => _i115.ScheduleRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i574.SubjectsRemoteDatasource>(
      () => _i574.SubjectsRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDatasource>(),
        gh<_i992.AuthLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i413.ExamRepository>(
      () => _i362.ExamRepositoryImpl(gh<_i977.ExamRemoteDatasource>()),
    );
    gh.lazySingleton<_i736.ScheduleRepository>(
      () => _i688.ScheduleRepositoryImpl(gh<_i115.ScheduleRemoteDatasource>()),
    );
    gh.factory<_i919.NotesCubit>(
      () => _i919.NotesCubit(gh<_i736.ScheduleRepository>()),
    );
    gh.factory<_i543.TasksCubit>(
      () => _i543.TasksCubit(gh<_i736.ScheduleRepository>()),
    );
    gh.factory<_i596.TimetableCubit>(
      () => _i596.TimetableCubit(gh<_i736.ScheduleRepository>()),
    );
    gh.factory<_i788.ChangePasswordUseCase>(
      () => _i788.ChangePasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i914.DeleteAccountUseCase>(
      () => _i914.DeleteAccountUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i560.ForgotPasswordUseCase>(
      () => _i560.ForgotPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i568.GetProfileUseCase>(
      () => _i568.GetProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i798.UpdateProfileUseCase>(
      () => _i798.UpdateProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i91.UploadFileUseCase>(
      () => _i91.UploadFileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i265.LessonsRepository>(
      () => _i393.LessonsRepositoryImpl(gh<_i753.LessonsRemoteDatasource>()),
    );
    gh.lazySingleton<_i1072.GetExamDetailUseCase>(
      () => _i1072.GetExamDetailUseCase(gh<_i413.ExamRepository>()),
    );
    gh.lazySingleton<_i347.GetExamsUseCase>(
      () => _i347.GetExamsUseCase(gh<_i413.ExamRepository>()),
    );
    gh.lazySingleton<_i891.SubmitExamResultUseCase>(
      () => _i891.SubmitExamResultUseCase(gh<_i413.ExamRepository>()),
    );
    gh.lazySingleton<_i0.HomeRepository>(
      () => _i76.HomeRepositoryImpl(gh<_i278.HomeRemoteDatasource>()),
    );
    gh.lazySingleton<_i200.CreateLessonUseCase>(
      () => _i200.CreateLessonUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i470.DeleteLessonImageUseCase>(
      () => _i470.DeleteLessonImageUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i896.DeleteLessonUseCase>(
      () => _i896.DeleteLessonUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i231.GetLessonByIdUseCase>(
      () => _i231.GetLessonByIdUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i1056.GetLessonImagesUseCase>(
      () => _i1056.GetLessonImagesUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i75.GetLessonProgressUseCase>(
      () => _i75.GetLessonProgressUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i46.GetLessonsUseCase>(
      () => _i46.GetLessonsUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i400.UpdateLessonProgressUseCase>(
      () => _i400.UpdateLessonProgressUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i969.UpdateLessonUseCase>(
      () => _i969.UpdateLessonUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i721.UpdateQuizFlashcardsUseCase>(
      () => _i721.UpdateQuizFlashcardsUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i847.UploadLessonImagesUseCase>(
      () => _i847.UploadLessonImagesUseCase(gh<_i265.LessonsRepository>()),
    );
    gh.lazySingleton<_i640.SubjectsRepository>(
      () => _i962.SubjectsRepositoryImpl(gh<_i574.SubjectsRemoteDatasource>()),
    );
    gh.lazySingleton<_i718.QuizletRepository>(
      () => _i364.QuizletRepositoryImpl(gh<_i237.QuizletRemoteDatasource>()),
    );
    gh.factory<_i966.LessonsListBloc>(
      () => _i966.LessonsListBloc(
        gh<_i46.GetLessonsUseCase>(),
        gh<_i75.GetLessonProgressUseCase>(),
        gh<_i896.DeleteLessonUseCase>(),
        gh<_i200.CreateLessonUseCase>(),
        gh<_i969.UpdateLessonUseCase>(),
        gh<_i721.UpdateQuizFlashcardsUseCase>(),
        gh<_i847.UploadLessonImagesUseCase>(),
        gh<_i470.DeleteLessonImageUseCase>(),
      ),
    );
    gh.factory<_i711.ExamPlayBloc>(
      () => _i711.ExamPlayBloc(gh<_i891.SubmitExamResultUseCase>()),
    );
    gh.lazySingleton<_i743.CreateQuizletUseCase>(
      () => _i743.CreateQuizletUseCase(gh<_i718.QuizletRepository>()),
    );
    gh.lazySingleton<_i231.DeleteQuizletUseCase>(
      () => _i231.DeleteQuizletUseCase(gh<_i718.QuizletRepository>()),
    );
    gh.lazySingleton<_i595.GetQuizletDetailUseCase>(
      () => _i595.GetQuizletDetailUseCase(gh<_i718.QuizletRepository>()),
    );
    gh.lazySingleton<_i1064.GetQuizletsUseCase>(
      () => _i1064.GetQuizletsUseCase(gh<_i718.QuizletRepository>()),
    );
    gh.lazySingleton<_i600.UpdateQuizletUseCase>(
      () => _i600.UpdateQuizletUseCase(gh<_i718.QuizletRepository>()),
    );
    gh.factory<_i591.ExamDetailBloc>(
      () => _i591.ExamDetailBloc(gh<_i1072.GetExamDetailUseCase>()),
    );
    gh.lazySingleton<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i568.GetProfileUseCase>(),
        gh<_i798.UpdateProfileUseCase>(),
        gh<_i992.AuthLocalDatasource>(),
      ),
    );
    gh.factory<_i104.ForgotPasswordCubit>(
      () => _i104.ForgotPasswordCubit(gh<_i560.ForgotPasswordUseCase>()),
    );
    gh.factory<_i729.ExamBloc>(
      () => _i729.ExamBloc(gh<_i347.GetExamsUseCase>()),
    );
    gh.lazySingleton<_i901.CreateCurriculumUseCase>(
      () => _i901.CreateCurriculumUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i644.DeleteCurriculumUseCase>(
      () => _i644.DeleteCurriculumUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i995.GetCurriculaBySubjectUseCase>(
      () => _i995.GetCurriculaBySubjectUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i638.GetSubjectDetailUseCase>(
      () => _i638.GetSubjectDetailUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i181.GetSubjectsUseCase>(
      () => _i181.GetSubjectsUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i502.UpdateCurriculumUseCase>(
      () => _i502.UpdateCurriculumUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i765.UploadImageUseCase>(
      () => _i765.UploadImageUseCase(gh<_i640.SubjectsRepository>()),
    );
    gh.lazySingleton<_i376.GetAllSubjectsUseCase>(
      () => _i376.GetAllSubjectsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i93.GetCurriculaUseCase>(
      () => _i93.GetCurriculaUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i535.GetLearningCategoriesUseCase>(
      () => _i535.GetLearningCategoriesUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i821.GetLearningQuestionsUseCase>(
      () => _i821.GetLearningQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i146.GetNNCQuestionsUseCase>(
      () => _i146.GetNNCQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i654.GetPictogramQuestionsUseCase>(
      () => _i654.GetPictogramQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i329.GetProverbQuestionsUseCase>(
      () => _i329.GetProverbQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i900.GetRandomDictationUseCase>(
      () => _i900.GetRandomDictationUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i185.GetSubjectsUseCase>(
      () => _i185.GetSubjectsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i839.GetUserSubjectsUseCase>(
      () => _i839.GetUserSubjectsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i182.GetVTVQuestionsUseCase>(
      () => _i182.GetVTVQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i541.SaveUserSubjectsUseCase>(
      () => _i541.SaveUserSubjectsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.factory<_i367.LessonDetailBloc>(
      () => _i367.LessonDetailBloc(
        gh<_i231.GetLessonByIdUseCase>(),
        gh<_i1056.GetLessonImagesUseCase>(),
        gh<_i75.GetLessonProgressUseCase>(),
        gh<_i400.UpdateLessonProgressUseCase>(),
      ),
    );
    gh.factory<_i518.QuizletDetailBloc>(
      () => _i518.QuizletDetailBloc(gh<_i595.GetQuizletDetailUseCase>()),
    );
    gh.factory<_i124.ProfileBloc>(
      () => _i124.ProfileBloc(
        gh<_i568.GetProfileUseCase>(),
        gh<_i798.UpdateProfileUseCase>(),
        gh<_i788.ChangePasswordUseCase>(),
        gh<_i914.DeleteAccountUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    gh.factory<_i252.QuizletBloc>(
      () => _i252.QuizletBloc(
        gh<_i1064.GetQuizletsUseCase>(),
        gh<_i231.DeleteQuizletUseCase>(),
      ),
    );
    gh.factory<_i130.DictationPlayBloc>(
      () => _i130.DictationPlayBloc(gh<_i900.GetRandomDictationUseCase>()),
    );
    gh.factory<_i496.QuizletCreateBloc>(
      () => _i496.QuizletCreateBloc(
        gh<_i743.CreateQuizletUseCase>(),
        gh<_i600.UpdateQuizletUseCase>(),
        gh<_i595.GetQuizletDetailUseCase>(),
        gh<_i181.GetSubjectsUseCase>(),
      ),
    );
    gh.lazySingleton<_i202.HomeBloc>(
      () => _i202.HomeBloc(
        gh<_i839.GetUserSubjectsUseCase>(),
        gh<_i93.GetCurriculaUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    gh.factory<_i910.CurriculumFormBloc>(
      () => _i910.CurriculumFormBloc(
        gh<_i901.CreateCurriculumUseCase>(),
        gh<_i502.UpdateCurriculumUseCase>(),
        gh<_i765.UploadImageUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    gh.lazySingleton<_i121.SubjectDetailBloc>(
      () => _i121.SubjectDetailBloc(
        gh<_i638.GetSubjectDetailUseCase>(),
        gh<_i995.GetCurriculaBySubjectUseCase>(),
        gh<_i644.DeleteCurriculumUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    gh.lazySingleton<_i900.SubjectsListBloc>(
      () => _i900.SubjectsListBloc(
        gh<_i839.GetUserSubjectsUseCase>(),
        gh<_i995.GetCurriculaBySubjectUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    return this;
  }
}

class _$TtsModule extends _i1038.TtsModule {}

class _$SecureStorageModule extends _i1071.SecureStorageModule {}

class _$SharedPreferencesModule extends _i205.SharedPreferencesModule {}

class _$DioModule extends _i571.DioModule {}

class _$AuthRemoteModule extends _i674.AuthRemoteModule {}
