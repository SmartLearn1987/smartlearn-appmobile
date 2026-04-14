import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/get_curricula.dart';
import '../../domain/usecases/get_subjects.dart';
import '../helpers/subject_count_helper.dart';
import '../models/subject_with_count.dart';
import '../../../../core/usecase/usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetSubjectsUseCase _getSubjects;
  final GetCurriculaUseCase _getCurricula;
  final AuthBloc _authBloc;

  HomeBloc(this._getSubjects, this._getCurricula, this._authBloc)
    : super(const HomeInitial()) {
    on<HomeLoadSubjects>(_onLoadSubjects);
  }

  Future<void> _onLoadSubjects(
    HomeLoadSubjects event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final results = await Future.wait([
      _getSubjects(const NoParams()),
      _getCurricula(const NoParams()),
    ]);

    final subjectsResult = results[0];
    final curriculaResult = results[1];

    subjectsResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
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

        emit(HomeLoaded(subjects: computed));
      },
    );
  }
}
