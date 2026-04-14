import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'login_response_model.g.dart';

/// The login API returns a flat JSON with user fields + sessionToken.
/// This factory extracts the sessionToken and builds a UserModel from
/// the same map.
@JsonSerializable()
class LoginResponseModel {
  final String sessionToken;
  final UserModel user;

  const LoginResponseModel({
    required this.sessionToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      sessionToken: json['sessionToken'] as String,
      user: UserModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...user.toJson(),
        'sessionToken': sessionToken,
      };
}
