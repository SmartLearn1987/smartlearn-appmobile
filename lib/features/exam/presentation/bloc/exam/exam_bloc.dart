import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/exam_entity.dart';
import '../../../domain/usecases/get_exams_use_case.dart';

part 'exam_event.dart';
part 'exam_state.dart';

@injectable
class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final GetExamsUseCase _getExams;

  ExamBloc(this._getExams) : super(const ExamInitial()) {
    on<LoadExams>(_onLoadExams);
    on<RefreshExams>(_onRefreshExams);
  }

  Future<void> _onLoadExams(LoadExams event, Emitter<ExamState> emit) async {
    emit(const ExamLoading());
    await _fetchExams(emit, tab: event.tab, search: event.search);
  }

  Future<void> _onRefreshExams(
    RefreshExams event,
    Emitter<ExamState> emit,
  ) async {
    emit(const ExamLoading());
    await _fetchExams(emit, tab: event.tab, search: event.search);
  }

  Future<void> _fetchExams(
    Emitter<ExamState> emit, {
    required String tab,
    required String search,
  }) async {
    final normalizedSearch = search.trim();
    final result = await _getExams(
      GetExamsParams(
        tab: tab,
        search: normalizedSearch.isEmpty ? null : normalizedSearch,
      ),
    );
    result.fold(
      (failure) => emit(ExamError(message: failure.message)),
      (exams) => emit(ExamLoaded(exams: exams)),
    );
  }
}
