import 'dart:io';

import 'package:equatable/equatable.dart';

class UploadImagesParams extends Equatable {
  final String lessonId;
  final List<File> images;

  const UploadImagesParams({required this.lessonId, required this.images});

  @override
  List<Object?> get props => [lessonId, images];
}
