import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';

@lazySingleton
class UploadImageUseCase extends UseCase<String, File> {
  final SubjectsRepository repository;

  UploadImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(File params) =>
      repository.uploadImage(params);
}
