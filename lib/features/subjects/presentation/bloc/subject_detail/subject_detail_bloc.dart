import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../home/domain/entities/subject_entity.dart';
import '../../../domain/entities/curriculum_entity.dart';
import '../../../domain/usecases/delete_curriculum_use_case.dart';
import '../../../domain/usecases/get_curricula_by_subject_use_case.dart';
import '../../../domain/usecases/get_subject_detail_use_case.dart';
import '../../helpers/curriculum_group_helper.dart';

part 'subject_detail_event.dart';
part 'subject_detail_state.dart';

@injectable
class SubjectDetailBloc
    extends Bloc<SubjectDetailEvent, SubjectDetailState> {
  final GetSubjectDetailUseCase _getSubjectDetail;
  final GetCurriculaBySubjectUseCase _getCurricula;
  final DeleteCurriculumUseCase _deleteCurriculum;
  final AuthBloc _authBloc;

  String _subjectId = '';

  SubjectDetailBloc(
    this._getSubjectDetail,
    this._getCurricula,
    this._deleteCurriculum,
    this._authBloc,
  ) : super(const SubjectDetailInitial()) {
    on<SubjectDetailLoadRequested>(_onLoadRequested);
    on<CurriculumDeleteRequested>(_onDeleteRequested);
    on<SubjectDetailRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    SubjectDetailLoadRequested event,
    Emitter<SubjectDetailState> emit,
  ) async {
    _subjectId = event.subjectId;
    emit(const SubjectDetailLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    SubjectDetailRefreshRequested event,
    Emitter<SubjectDetailState> emit,
  ) async {
    emit(const SubjectDetailLoading());
    await _loadData(emit);
  }

  Future<void> _onDeleteRequested(
    CurriculumDeleteRequested event,
    Emitter<SubjectDetailState> emit,
  ) async {
    final result = await _deleteCurriculum(event.curriculumId);
    result.fold(
      (failure) => emit(CurriculumDeleteFailure(message: failure.message)),
      (_) {
        emit(const CurriculumDeleteSuccess());
        add(const SubjectDetailRefreshRequested());
      },
    );
  }

  Future<void> _loadData(Emitter<SubjectDetailState> emit) async {
    final results = await Future.wait([
      _getSubjectDetail(_subjectId),
      _getCurricula(_subjectId),
    ]);

    final subjectResult = results[0];
    final curriculaResult = results[1];

    subjectResult.fold(
      (failure) => emit(SubjectDetailError(message: failure.message)),
      (subject) {
        final userId = _authBloc.state is AuthAuthenticated
            ? (_authBloc.state as AuthAuthenticated).user.id
            : '';

        final allCurricula = curriculaResult.fold(
          (_) => <CurriculumEntity>[],
          (data) => (data as List<CurriculumEntity>),
        );

        final userCurricula =
            allCurricula.where((c) => c.createdBy == userId).toList();

        final grouped = groupCurriculaByLevel(userCurricula);

        emit(SubjectDetailLoaded(
          subject: subject as SubjectEntity,
          groupedCurricula: grouped,
        ));
      },
    );
  }
}
