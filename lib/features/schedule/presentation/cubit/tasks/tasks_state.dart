part of 'tasks_cubit.dart';

enum TasksStatus { initial, loaded, error }

class TasksState extends Equatable {
  final List<TaskItemEntity> tasks;
  final String filter;
  final bool isAddingTask;
  final TaskItemEntity? editingTask;
  final TaskItemEntity? viewingTask;
  final Set<String> collapsedMonths;
  final TasksStatus status;
  final String? errorMessage;

  const TasksState({
    this.tasks = const [],
    this.filter = 'all',
    this.isAddingTask = false,
    this.editingTask,
    this.viewingTask,
    this.collapsedMonths = const {},
    this.status = TasksStatus.initial,
    this.errorMessage,
  });

  TasksState copyWith({
    List<TaskItemEntity>? tasks,
    String? filter,
    bool? isAddingTask,
    TaskItemEntity? editingTask,
    TaskItemEntity? viewingTask,
    Set<String>? collapsedMonths,
    TasksStatus? status,
    String? errorMessage,
  }) =>
      TasksState(
        tasks: tasks ?? this.tasks,
        filter: filter ?? this.filter,
        isAddingTask: isAddingTask ?? this.isAddingTask,
        editingTask: editingTask ?? this.editingTask,
        viewingTask: viewingTask ?? this.viewingTask,
        collapsedMonths: collapsedMonths ?? this.collapsedMonths,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        tasks,
        filter,
        isAddingTask,
        editingTask,
        viewingTask,
        collapsedMonths,
        status,
        errorMessage,
      ];
}
