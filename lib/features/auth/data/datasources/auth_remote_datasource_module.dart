import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'auth_remote_datasource.dart';

@module
abstract class AuthRemoteModule {
  @lazySingleton
  AuthRemoteDatasource authRemoteDatasource(Dio dio) =>
      AuthRemoteDatasource(dio);
}
