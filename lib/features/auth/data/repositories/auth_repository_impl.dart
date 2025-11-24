import 'package:dartz/dartz.dart';
import 'package:wiseman_iot/core/error/exceptions.dart';
import 'package:wiseman_iot/core/error/failures.dart';
import 'package:wiseman_iot/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_request_model.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_response_model.dart';

/// Repository interface for authentication operations
abstract class IAuthRepository {
  /// Login with account credentials
  /// Returns [AuthResponseModel] on success or [Failure] on error
  Future<Either<Failure, AuthResponseModel>> login(
    String accountName,
    String md5Password,
  );
}

/// Implementation of auth repository
/// Handles error mapping from exceptions to failures
class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthResponseModel>> login(
    String accountName,
    String md5Password,
  ) async {
    try {
      final request = AuthRequestModel(
        accountName: accountName,
        password: md5Password,
      );

      final response = await remoteDataSource.login(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          resultCode: e.resultCode,
          reason: e.reason,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on DataParsingException catch (e) {
      return Left(DataParsingFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }
}
