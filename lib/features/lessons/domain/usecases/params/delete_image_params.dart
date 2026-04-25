import 'package:equatable/equatable.dart';

class DeleteImageParams extends Equatable {
  final String lessonId;
  final String imageId;

  const DeleteImageParams({required this.lessonId, required this.imageId});

  @override
  List<Object?> get props => [lessonId, imageId];
}
