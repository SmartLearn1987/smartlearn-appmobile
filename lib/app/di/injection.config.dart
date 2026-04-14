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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/network/auth_interceptor.dart' as _i388;
import '../../core/network/dio_client.dart' as _i571;
import '../../core/storage/secure_storage_module.dart' as _i1071;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/datasources/auth_remote_datasource_module.dart'
    as _i674;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i560;
import '../../features/auth/domain/usecases/get_profile_usecase.dart' as _i568;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/update_profile_usecase.dart'
    as _i798;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart'
    as _i104;
import '../../features/home/data/datasources/home_remote_datasource.dart'
    as _i278;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/usecases/get_curricula.dart' as _i93;
import '../../features/home/domain/usecases/get_pictogram_questions.dart'
    as _i654;
import '../../features/home/domain/usecases/get_random_dictation.dart' as _i900;
import '../../features/home/domain/usecases/get_subjects.dart' as _i185;
import '../../features/home/presentation/bloc/focus_cubit.dart' as _i128;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
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
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final secureStorageModule = _$SecureStorageModule();
    final dioModule = _$DioModule();
    final authRemoteModule = _$AuthRemoteModule();
    gh.factory<_i128.FocusCubit>(() => _i128.FocusCubit());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage,
    );
    gh.lazySingleton<_i992.AuthLocalDatasource>(
      () => _i992.AuthLocalDatasource(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i388.AuthInterceptor>(
      () => _i388.AuthInterceptor(gh<_i992.AuthLocalDatasource>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i388.AuthInterceptor>()),
    );
    gh.lazySingleton<_i161.AuthRemoteDatasource>(
      () => authRemoteModule.authRemoteDatasource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i278.HomeRemoteDatasource>(
      () => _i278.HomeRemoteDatasource(gh<_i361.Dio>()),
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
    gh.lazySingleton<_i0.HomeRepository>(
      () => _i76.HomeRepositoryImpl(gh<_i278.HomeRemoteDatasource>()),
    );
    gh.lazySingleton<_i640.SubjectsRepository>(
      () => _i962.SubjectsRepositoryImpl(gh<_i574.SubjectsRemoteDatasource>()),
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
    gh.lazySingleton<_i93.GetCurriculaUseCase>(
      () => _i93.GetCurriculaUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i654.GetPictogramQuestionsUseCase>(
      () => _i654.GetPictogramQuestionsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i900.GetRandomDictationUseCase>(
      () => _i900.GetRandomDictationUseCase(gh<_i0.HomeRepository>()),
    );
    gh.lazySingleton<_i185.GetSubjectsUseCase>(
      () => _i185.GetSubjectsUseCase(gh<_i0.HomeRepository>()),
    );
    gh.factory<_i900.SubjectsListBloc>(
      () => _i900.SubjectsListBloc(
        gh<_i181.GetSubjectsUseCase>(),
        gh<_i995.GetCurriculaBySubjectUseCase>(),
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
    gh.factory<_i121.SubjectDetailBloc>(
      () => _i121.SubjectDetailBloc(
        gh<_i638.GetSubjectDetailUseCase>(),
        gh<_i995.GetCurriculaBySubjectUseCase>(),
        gh<_i644.DeleteCurriculumUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    gh.factory<_i202.HomeBloc>(
      () => _i202.HomeBloc(
        gh<_i185.GetSubjectsUseCase>(),
        gh<_i93.GetCurriculaUseCase>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    return this;
  }
}

class _$SecureStorageModule extends _i1071.SecureStorageModule {}

class _$DioModule extends _i571.DioModule {}

class _$AuthRemoteModule extends _i674.AuthRemoteModule {}
