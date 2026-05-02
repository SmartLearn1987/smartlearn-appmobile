part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

final class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? avatarUrl;

  const UpdateProfile({this.displayName, this.avatarUrl});

  @override
  List<Object?> get props => [displayName, avatarUrl];
}

final class ChangePassword extends ProfileEvent {
  final String newPassword;

  const ChangePassword({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

final class AccountDeleteRequested extends ProfileEvent {
  final String reason;

  const AccountDeleteRequested({required this.reason});

  @override
  List<Object?> get props => [reason];
}
