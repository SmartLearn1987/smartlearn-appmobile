import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';

part 'quizlet_term_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QuizletTermModel extends QuizletTermEntity {
  const QuizletTermModel({
    required super.id,
    required super.term,
    required super.definition,
    super.imageUrl,
    required super.sortOrder,
  });

  factory QuizletTermModel.fromJson(Map<String, dynamic> json) =>
      _$QuizletTermModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizletTermModelToJson(this);
}
