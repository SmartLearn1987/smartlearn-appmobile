import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/login_response_model.dart';
import '../models/refresh_token_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDatasource {
  factory AuthRemoteDatasource(Dio dio, {String baseUrl}) =
      _AuthRemoteDatasource;

  @POST('/login')
  Future<LoginResponseModel> login(@Body() Map<String, dynamic> body);

  @POST('/register')
  Future<void> register(@Body() Map<String, dynamic> body);

  @POST('/refresh-token')
  Future<RefreshTokenResponseModel> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  @GET('/me')
  Future<UserModel> getProfile();

  @PUT('/profile')
  Future<UserModel> updateProfile(@Body() Map<String, dynamic> body);

  @POST('/forgot-password')
  Future<void> forgotPassword(@Body() Map<String, dynamic> body);

  @PUT('/users/{id}/password')
  Future<void> changePassword(
    @Path('id') String userId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/users/{id}')
  Future<void> deleteAccount(
    @Path('id') String userId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/upload')
  @MultiPart()
  Future<String> uploadFile(
    @Part(name: 'file') File file,
  );
}
