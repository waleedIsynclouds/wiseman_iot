import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Interceptor for logging all WisMan HTTP requests and responses
/// Logs method, URL, headers, request/response bodies, and errors
class WisManLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '╔════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Request',
    );
    developer.log('║ ${options.method} ${options.uri}', name: 'WisMan Request');
    developer.log('║ Headers:', name: 'WisMan Request');
    options.headers.forEach((key, value) {
      developer.log('║   $key: $value', name: 'WisMan Request');
    });
    developer.log('║ Body: ${options.data}', name: 'WisMan Request');
    developer.log(
      '╚════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Request',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '╔════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Response',
    );
    developer.log('║ Status: ${response.statusCode}', name: 'WisMan Response');
    developer.log('║ Data: ${response.data}', name: 'WisMan Response');
    developer.log(
      '╚════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Response',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '╔════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Error',
    );
    developer.log('║ Error: ${err.message}', name: 'WisMan Error');
    developer.log('║ Type: ${err.type}', name: 'WisMan Error');
    if (err.response != null) {
      developer.log('║ Response: ${err.response?.data}', name: 'WisMan Error');
    }
    developer.log('║ StackTrace: ${err.stackTrace}', name: 'WisMan Error');
    developer.log(
      '╚════════════════════════════════════════════════════════════════════════',
      name: 'WisMan Error',
    );
    super.onError(err, handler);
  }
}
