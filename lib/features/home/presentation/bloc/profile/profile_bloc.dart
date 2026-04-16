import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:smart_learn/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final AuthBloc _authBloc;

  ProfileBloc(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._changePasswordUseCase,
    this._authBloc,
  ) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangePassword>(_onChangePassword);
  }

  UserEntity? _getCurrentUser() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.user;
    if (currentState is ProfileUpdating) return currentState.user;
    if (currentState is ProfileUpdateSuccess) return currentState.user;
    if (currentState is ProfilePasswordChanged) return currentState.user;
    return null;
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfileUseCase(const NoParams());
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      emit(const ProfileError('No user data available'));
      return;
    }

    emit(ProfileUpdating(currentUser));
    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: event.displayName,
        avatarUrl: event.avatarUrl,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (updatedUser) {
        emit(ProfileUpdateSuccess(updatedUser));
        _authBloc.add(AuthProfileUpdateRequested(
          name: event.displayName,
          avatarUrl: event.avatarUrl,
        ));
      },
    );
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      emit(const ProfileError('No user data available'));
      return;
    }

    emit(ProfileUpdating(currentUser));
    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        userId: currentUser.id,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfilePasswordChanged(currentUser)),
    );
  }
}
