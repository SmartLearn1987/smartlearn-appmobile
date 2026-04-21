import 'package:equatable/equatable.dart';

class LearningCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String generalQuestion;
  final int itemCount;

  const LearningCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.generalQuestion,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [id, name, description, generalQuestion, itemCount];
}
