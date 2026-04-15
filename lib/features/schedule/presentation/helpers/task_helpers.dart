import '../../domain/entities/task_item_entity.dart';

/// Groups tasks by their [dueDate] month using format "Tháng M · yyyy".
///
/// Tasks with null [dueDate] go into the "Không có hạn chót" group.
Map<String, List<TaskItemEntity>> groupTasksByMonth(
  List<TaskItemEntity> tasks,
) {
  final map = <String, List<TaskItemEntity>>{};
  for (final task in tasks) {
    final key = task.dueDate != null
        ? 'Tháng ${task.dueDate!.month} · ${task.dueDate!.year}'
        : 'Không có hạn chót';
    map.putIfAbsent(key, () => []).add(task);
  }
  return map;
}

/// Computes the completed/total ratio for a list of tasks.
///
/// Returns 0.0 for an empty list.
double computeMonthProgress(List<TaskItemEntity> tasks) {
  if (tasks.isEmpty) return 0.0;
  final completed = tasks.where((t) => t.completed).length;
  return completed / tasks.length;
}

/// Filters tasks by completion status.
///
/// - "all" returns all tasks
/// - "inProgress" returns tasks where [completed] is false
/// - "completed" returns tasks where [completed] is true
List<TaskItemEntity> filterTasks(List<TaskItemEntity> tasks, String filter) {
  switch (filter) {
    case 'inProgress':
      return tasks.where((t) => !t.completed).toList();
    case 'completed':
      return tasks.where((t) => t.completed).toList();
    case 'all':
    default:
      return List.of(tasks);
  }
}

/// Sorts tasks by [dueDate] ascending. Null dueDates go to the end.
List<TaskItemEntity> sortTasksByDueDate(List<TaskItemEntity> tasks) =>
    List.of(tasks)
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
