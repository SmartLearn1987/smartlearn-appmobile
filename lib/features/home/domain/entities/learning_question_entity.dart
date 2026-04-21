import 'package:equatable/equatable.dart';

class LearningQuestionEntity extends Equatable {
  final String id;
  final String categoryId;
  final String imageUrl;
  final String answer;

  const LearningQuestionEntity({
    required this.id,
    required this.categoryId,
    required this.imageUrl,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, categoryId, imageUrl, answer];
}
