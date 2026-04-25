import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/login_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/logout_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/register_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/update_profile_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final AuthLocalDatasource _localDatasource;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._localDatasource,
  ) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthProfileRequested>(_onProfileRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthForceLogout>(_onForceLogout);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) => emit(AuthAuthenticated(data.$1)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
        educationLevel: event.educationLevel,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthRegistrationSuccess()),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasTokens = await _localDatasource.hasTokens();
    if (!hasTokens) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _getProfileUseCase(const NoParams());
    await result.fold(
      (failure) async {
        await _localDatasource.clearTokens();
        emit(const AuthUnauthenticated());
      },
      (user) async => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onProfileRequested(
    AuthProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getProfileUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        username: event.username,
        avatarUrl: event.avatarUrl,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onForceLogout(
    AuthForceLogout event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthUnauthenticated(message: event.message));
  }
}
