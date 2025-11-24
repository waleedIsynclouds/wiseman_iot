import 'package:dartz/dartz.dart';
import 'package:wiseman_iot/core/error/failures.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_response_model.dart';
import 'package:wiseman_iot/features/auth/data/repositories/auth_repository_impl.dart';

/// Use case for user login
/// Encapsulates the business logic for authentication
class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute login with account credentials
  /// [accountName] - The account name
  /// [password] - MD5 hashed password
  /// Returns [AuthResponseModel] on success or [Failure] on error
  Future<Either<Failure, AuthResponseModel>> call({
    required String accountName,
    required String password,
  }) {
    return repository.login(accountName, password);
  }
}
