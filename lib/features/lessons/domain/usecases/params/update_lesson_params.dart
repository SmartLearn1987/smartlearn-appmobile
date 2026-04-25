import 'package:equatable/equatable.dart';

class UpdateLessonParams extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const UpdateLessonParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}
