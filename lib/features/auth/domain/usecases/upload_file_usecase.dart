import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/repositories/auth_repository.dart';

@injectable
class UploadFileUseCase extends UseCase<String, File> {
  final AuthRepository _repository;

  UploadFileUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(File params) =>
      _repository.uploadFile(params);
}
