import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/exam_detail_entity.dart';
import '../../../domain/usecases/get_exam_detail_use_case.dart';

part 'exam_detail_event.dart';
part 'exam_detail_state.dart';

@injectable
class ExamDetailBloc extends Bloc<ExamDetailEvent, ExamDetailState> {
  final GetExamDetailUseCase _getExamDetail;

  ExamDetailBloc(this._getExamDetail) : super(const ExamDetailInitial()) {
    on<LoadExamDetail>(_onLoadExamDetail);
  }

  Future<void> _onLoadExamDetail(
    LoadExamDetail event,
    Emitter<ExamDetailState> emit,
  ) async {
    emit(const ExamDetailLoading());
    final result = await _getExamDetail(event.examId);
    result.fold(
      (failure) => emit(ExamDetailError(message: failure.message)),
      (detail) => emit(ExamDetailLoaded(detail: detail)),
    );
  }
}
