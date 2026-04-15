import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/task_item_entity.dart';
import '../../../domain/repositories/schedule_local_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'tasks_state.dart';

@injectable
class TasksCubit extends Cubit<TasksState> {
  final ScheduleLocalRepository _repository;

  TasksCubit(this._repository) : super(const TasksState());

  void loadTasks() {
    final result = _repository.getTasks();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (tasks) => emit(
        state.copyWith(
          tasks: tasks,
          status: TasksStatus.loaded,
        ),
      ),
    );
  }

  void addTask(TaskItemEntity task) {
    final error = validateTaskTitle(task.title);
    if (error != null) {
      emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    final updatedTasks = [...state.tasks, task];
    emit(
      state.copyWith(
        tasks: updatedTasks,
        isAddingTask: false,
        status: TasksStatus.loaded,
      ),
    );
    _saveTasks();
  }

  void editTask(TaskItemEntity task) {
    final error = validateTaskTitle(task.title);
    if (error != null) {
      emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: error,
        ),
      );
      return;
    }

    final updatedTasks =
        state.tasks.map((t) => t.id == task.id ? task : t).toList();
    emit(
      state.copyWith(
        tasks: updatedTasks,
        editingTask: null,
        status: TasksStatus.loaded,
      ),
    );
    _saveTasks();
  }

  void deleteTask(String taskId) {
    final updatedTasks =
        state.tasks.where((t) => t.id != taskId).toList();
    emit(
      state.copyWith(
        tasks: updatedTasks,
        status: TasksStatus.loaded,
      ),
    );
    _saveTasks();
  }

  void toggleCompletion(String taskId) {
    final updatedTasks = state.tasks.map((t) {
      if (t.id == taskId) {
        return TaskItemEntity(
          id: t.id,
          title: t.title,
          description: t.description,
          dueDate: t.dueDate,
          completed: !t.completed,
          priority: t.priority,
          createdAt: t.createdAt,
        );
      }
      return t;
    }).toList();
    emit(
      state.copyWith(
        tasks: updatedTasks,
        status: TasksStatus.loaded,
      ),
    );
    _saveTasks();
  }

  void changeFilter(String filter) {
    emit(state.copyWith(filter: filter));
  }

  void toggleMonthCollapse(String monthKey) {
    final updatedCollapsed = Set<String>.from(state.collapsedMonths);
    if (updatedCollapsed.contains(monthKey)) {
      updatedCollapsed.remove(monthKey);
    } else {
      updatedCollapsed.add(monthKey);
    }
    emit(state.copyWith(collapsedMonths: updatedCollapsed));
  }

  void toggleAddForm() {
    emit(state.copyWith(isAddingTask: !state.isAddingTask));
  }

  void setEditingTask(TaskItemEntity? task) {
    emit(state.copyWith(editingTask: task));
  }

  void setViewingTask(TaskItemEntity? task) {
    emit(state.copyWith(viewingTask: task));
  }

  Future<void> _saveTasks() async {
    await _repository.saveTasks(state.tasks);
  }
}
