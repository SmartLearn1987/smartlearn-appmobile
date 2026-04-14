import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String role;
  final bool isActive;
  final String? educationLevel;
  final String? plan;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
    this.educationLevel,
    this.plan,
    this.planStartDate,
    this.planEndDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        displayName,
        role,
        isActive,
        educationLevel,
        plan,
        planStartDate,
        planEndDate,
        createdAt,
      ];
}
