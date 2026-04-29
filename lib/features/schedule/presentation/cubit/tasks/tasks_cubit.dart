import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/task_item_entity.dart';
import '../../../domain/repositories/schedule_repository.dart';
import '../../../domain/validators/schedule_validators.dart';

part 'tasks_state.dart';

@injectable
class TasksCubit extends Cubit<TasksState> {
  final ScheduleRepository _repository;

  TasksCubit(this._repository) : super(const TasksState());

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TasksStatus.loading));
    final result = await _repository.getTasks();
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

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime? dueDate,
    required String priority,
  }) async {
    final error = validateTaskTitle(title);
    if (error != null) {
      emit(state.copyWith(status: TasksStatus.error, errorMessage: error));
      return;
    }

    final result = await _repository.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newTask) {
        emit(
          state.copyWith(
            tasks: [newTask, ...state.tasks],
            isAddingTask: false,
            status: TasksStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> editTask(TaskItemEntity task) async {
    final error = validateTaskTitle(task.title);
    if (error != null) {
      emit(state.copyWith(status: TasksStatus.error, errorMessage: error));
      return;
    }

    final result = await _repository.updateTask(
      taskId: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedTask) {
        final updatedTasks =
            state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
        emit(
          state.copyWith(
            tasks: updatedTasks,
            clearEditingTask: true,
            status: TasksStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await _repository.deleteTask(taskId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            tasks: state.tasks.where((t) => t.id != taskId).toList(),
            status: TasksStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> toggleCompletion(String taskId) async {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    final result = await _repository.updateTask(
      taskId: taskId,
      completed: !task.completed,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TasksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedTask) {
        final updatedTasks =
            state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
        emit(state.copyWith(tasks: updatedTasks, status: TasksStatus.loaded));
      },
    );
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
    if (task != null && state.editingTask != null) {
      emit(state.copyWith(clearEditingTask: true));
    }
    if (task == null) {
      emit(state.copyWith(clearEditingTask: true));
    } else {
      emit(state.copyWith(editingTask: task));
    }
  }

  void setViewingTask(TaskItemEntity? task) {
    if (task != null && state.viewingTask != null) {
      emit(state.copyWith(clearViewingTask: true));
    }
    if (task == null) {
      emit(state.copyWith(clearViewingTask: true));
    } else {
      emit(state.copyWith(viewingTask: task));
    }
  }
}
