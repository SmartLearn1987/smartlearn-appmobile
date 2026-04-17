import 'package:json_annotation/json_annotation.dart';

part 'refresh_token_response_model.g.dart';

@JsonSerializable()
class RefreshTokenResponseModel {
  final String sessionToken;
  final String refreshToken;
  final String accessTokenExpiresAt;

  const RefreshTokenResponseModel({
    required this.sessionToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseModelToJson(this);
}
