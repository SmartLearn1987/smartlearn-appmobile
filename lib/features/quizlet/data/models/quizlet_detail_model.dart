import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';

import 'quizlet_term_model.dart';

part 'quizlet_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizletDetailModel extends QuizletDetailEntity {
  @override
  final List<QuizletTermModel> terms;

  const QuizletDetailModel({
    required super.id,
    required super.title,
    super.description,
    required super.subjectName,
    required this.terms,
  }) : super(terms: terms);

  factory QuizletDetailModel.fromJson(Map<String, dynamic> json) =>
      _$QuizletDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizletDetailModelToJson(this);
}
