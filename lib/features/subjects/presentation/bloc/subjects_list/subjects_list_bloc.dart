import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/usecases/get_curricula_by_subject_use_case.dart';
import '../../../domain/usecases/get_subjects_use_case.dart';
import '../../helpers/subject_count_helper.dart';
import '../../models/subject_with_count.dart';

part 'subjects_list_event.dart';
part 'subjects_list_state.dart';

@injectable
class SubjectsListBloc extends Bloc<SubjectsListEvent, SubjectsListState> {
  final GetSubjectsUseCase _getSubjects;
  final GetCurriculaBySubjectUseCase _getCurricula;
  final AuthBloc _authBloc;

  SubjectsListBloc(
    this._getSubjects,
    this._getCurricula,
    this._authBloc,
  ) : super(const SubjectsListInitial()) {
    on<SubjectsListLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    SubjectsListLoadRequested event,
    Emitter<SubjectsListState> emit,
  ) async {
    emit(const SubjectsListLoading());

    final results = await Future.wait([
      _getSubjects(const NoParams()),
      _getCurricula(''),
    ]);

    final subjectsResult = results[0];
    final curriculaResult = results[1];

    subjectsResult.fold(
      (failure) => emit(SubjectsListError(message: failure.message)),
      (subjects) {
        final userId = _authBloc.state is AuthAuthenticated
            ? (_authBloc.state as AuthAuthenticated).user.id
            : '';

        final curricula = curriculaResult.fold(
          (_) => <dynamic>[],
          (data) => data,
        );

        final computed = computeSubjectCounts(
          subjects.cast(),
          curricula.cast(),
          userId,
        );

        emit(SubjectsListLoaded(subjects: computed));
      },
    );
  }
}
