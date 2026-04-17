import 'user_model.dart';

/// The login API returns a flat JSON with user fields + sessionToken,
/// refreshToken, and accessTokenExpiresAt.
/// This factory extracts the token fields and builds a UserModel from
/// the same map.
class LoginResponseModel {
  final String sessionToken;
  final String refreshToken;
  final String accessTokenExpiresAt;
  final UserModel user;

  const LoginResponseModel({
    required this.sessionToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      sessionToken: json['sessionToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as String,
      user: UserModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...user.toJson(),
        'sessionToken': sessionToken,
        'refreshToken': refreshToken,
        'accessTokenExpiresAt': accessTokenExpiresAt,
      };
}
