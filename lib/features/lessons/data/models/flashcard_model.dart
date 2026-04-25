import 'package:json_annotation/json_annotation.dart';
import 'package:smart_learn/features/lessons/domain/entities/flashcard.dart';

part 'flashcard_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FlashcardModel extends Flashcard {
  const FlashcardModel({
    required super.id,
    super.lessonId,
    required super.front,
    required super.back,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardModelToJson(this);
}
