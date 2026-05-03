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
  final String? email;

  const UpdateProfile({this.displayName, this.avatarUrl, this.email});

  @override
  List<Object?> get props => [displayName, avatarUrl, email];
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
