import 'package:equatable/equatable.dart';

class UpdateQuizFlashcardsParams extends Equatable {
  final String lessonId;
  final Map<String, dynamic> data;

  const UpdateQuizFlashcardsParams({
    required this.lessonId,
    required this.data,
  });

  @override
  List<Object?> get props => [lessonId, data];
}
