part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

final class ProfileUpdating extends ProfileState {
  final UserEntity user;

  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

final class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

final class ProfilePasswordChanged extends ProfileState {
  final UserEntity user;

  const ProfilePasswordChanged(this.user);

  @override
  List<Object?> get props => [user];
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

final class AccountDeleting extends ProfileState {
  final UserEntity user;

  const AccountDeleting(this.user);

  @override
  List<Object?> get props => [user];
}

final class AccountDeleted extends ProfileState {
  const AccountDeleted();
}
