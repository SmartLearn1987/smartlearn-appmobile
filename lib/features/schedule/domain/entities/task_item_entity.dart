import 'package:equatable/equatable.dart';

class TaskItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool completed;
  final String priority;
  final DateTime createdAt;

  const TaskItemEntity({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.completed,
    required this.priority,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        completed,
        priority,
        createdAt,
      ];
}
