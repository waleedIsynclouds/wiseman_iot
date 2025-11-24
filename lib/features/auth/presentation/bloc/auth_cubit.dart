import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wiseman_iot/features/auth/domain/usecases/login_usecase.dart';
import 'package:wiseman_iot/features/auth/presentation/bloc/auth_state.dart';

/// Cubit for managing authentication state
/// Handles login operations and state transitions
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;

  AuthCubit(this.loginUseCase) : super(AuthInitial());

  /// Perform login with account credentials
  /// [accountName] - The account name
  /// [password] - MD5 hashed password
  Future<void> login({
    required String accountName,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      accountName: accountName,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (auth) => emit(AuthSuccess(auth)),
    );
  }

  /// Reset to initial state
  void reset() {
    emit(AuthInitial());
  }
}
