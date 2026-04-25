import 'package:equatable/equatable.dart';

class CreateLessonParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateLessonParams({required this.data});

  @override
  List<Object?> get props => [data];
}
