import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_learn/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:smart_learn/features/auth/presentation/cubit/forgot_password_state.dart';

@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  ForgotPasswordCubit(this._forgotPasswordUseCase)
      : super(const ForgotPasswordInitial());

  Future<void> forgotPassword(String email) async {
    emit(const ForgotPasswordLoading());
    final result = await _forgotPasswordUseCase(
      ForgotPasswordParams(email: email),
    );
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
