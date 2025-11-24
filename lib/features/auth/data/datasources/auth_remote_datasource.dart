import 'package:wiseman_iot/core/network/wisman.dart';
import 'package:wiseman_iot/core/utils/encryption_util.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_request_model.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_response_model.dart';

/// Remote data source for authentication operations
/// Handles communication with WisMan backend for auth-related API calls
abstract class IAuthRemoteDataSource {
  /// Login with account credentials
  /// Calls the 'apartmentLogin' method on WisMan
  /// Throws [ServerException] on API errors
  /// Throws [NetworkException] on connectivity issues
  Future<AuthResponseModel> login(AuthRequestModel request);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final WisMan wisMan;

  AuthRemoteDataSource(this.wisMan);

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    final encryptedPassword = EncryptionUtil.md5Encrypt(request.password);
    // Call WisMan apartmentLogin method

    final data = await wisMan.call(
      method: 'apartmentLogin',
      data: request.copyWith(password: encryptedPassword).toMap(),
    );

    // Parse and return response
    return AuthResponseModel.fromJson(data);
  }
}
