import 'package:dio/dio.dart';
import 'package:wiseman_iot/core/error/exceptions.dart';
import 'package:wiseman_iot/core/network/wisman_logging_interceptor.dart';
import 'package:wiseman_iot/core/utils/msg_id_generator.dart';

/// WisMan HTTP client for all backend communication
/// Handles the custom JSON envelope protocol required by WisMan platform
///
/// All requests follow the format:
/// {
///   "msgId": <int>,
///   "method": "<method_name>",
///   "tokenId": "<optional_token>",
///   "data": { ... }
/// }
///
/// All responses follow the format:
/// {
///   "msgId": <int>,
///   "method": "<method_name>",
///   "resultCode": <int>,  // 0 = success, non-zero = error
///   "reason": "<error_message>",
///   "data": { ... }
/// }
class WisMan {
  final Dio _dio;

  // WisMan configuration - update these values based on your environment
  static const String baseUrl =
      'https://t-server.hxjiot.com'; // TODO: Update with actual WisMan server URL

  WisMan(this._dio) {
    _configureDio();
  }

  /// Configure Dio with WisMan-specific settings
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'text/json; charset=utf-8',
        'Content-Version': '1.0',
      },
    );

    // Add logging interceptor
    _dio.interceptors.add(WisManLoggingInterceptor());
  }

  /// Make a WisMan API call
  ///
  /// [method] - The WisMan service method name (e.g., 'apartmentLogin')
  /// [data] - The method-specific data payload
  /// [msgId] - Optional message ID (auto-generated if not provided)
  /// [tokenId] - Optional authentication token (only included if provided)
  ///
  /// Returns the 'data' field from the response on success
  /// Throws [ServerException] if resultCode != 0
  /// Throws [NetworkException] on connectivity issues
  /// Throws [DataParsingException] on JSON parsing errors
  Future<Map<String, dynamic>> call({
    required String method,
    required Map<String, dynamic> data,
    int? msgId,
    String? tokenId,
  }) async {
    try {
      // Build the WisMan envelope
      final requestBody = <String, dynamic>{'method': method, 'data': data};
      if (msgId != null) {
        requestBody['msgId'] = msgId;
      }
      // Only include tokenId if provided
      if (tokenId != null && tokenId.isNotEmpty) {
        requestBody['tokenId'] = tokenId;
      }

      // Make the POST request
      final response = await _dio.post(baseUrl, data: requestBody);

      // Parse response
      if (response.data == null) {
        throw DataParsingException('Response data is null');
      }

      final responseData = response.data as Map<String, dynamic>;
      final resultCode = responseData['resultCode'] as int? ?? -1;
      final reason = responseData['reason'] as String? ?? 'Unknown error';

      // Check for errors
      if (resultCode != 0) {
        throw ServerException(
          message: reason,
          resultCode: resultCode,
          reason: reason,
        );
      }

      // Return the data field
      return responseData['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout: ${e.message}');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Connection error: ${e.message}');
      } else if (e.response?.data != null) {
        // Try to parse error from response
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final resultCode = errorData['resultCode'] as int? ?? -1;
          final reason =
              errorData['reason'] as String? ?? e.message ?? 'Unknown error';
          throw ServerException(
            message: reason,
            resultCode: resultCode,
            reason: reason,
          );
        } catch (_) {
          throw NetworkException('Network error: ${e.message}');
        }
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on DataParsingException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Unexpected error: $e');
    }
  }
}
