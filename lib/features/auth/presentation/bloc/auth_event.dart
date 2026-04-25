part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

final class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? educationLevel;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    this.educationLevel,
  });

  @override
  List<Object?> get props => [username, email, password, educationLevel];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

final class AuthProfileRequested extends AuthEvent {
  const AuthProfileRequested();
}

final class AuthProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? username;
  final String? avatarUrl;

  const AuthProfileUpdateRequested({this.name, this.username, this.avatarUrl});

  @override
  List<Object?> get props => [name, username, avatarUrl];
}

final class AuthForceLogout extends AuthEvent {
  final String? message;

  const AuthForceLogout({this.message});

  @override
  List<Object?> get props => [message];
}
