import 'package:equatable/equatable.dart';

class UpdateProgressParams extends Equatable {
  final String lessonId;
  final Map<String, dynamic> data;

  const UpdateProgressParams({required this.lessonId, required this.data});

  @override
  List<Object?> get props => [lessonId, data];
}
