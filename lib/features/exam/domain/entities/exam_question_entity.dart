import 'package:equatable/equatable.dart';

import 'exam_option_entity.dart';

class ExamQuestionEntity extends Equatable {
  final String id;
  final String content;
  final String type;
  final int sortOrder;
  final List<ExamOptionEntity> options;

  const ExamQuestionEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.sortOrder,
    required this.options,
  });

  @override
  List<Object?> get props => [id, content, type, sortOrder, options];
}
