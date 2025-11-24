/// Custom exceptions for the application
class ServerException implements Exception {
  final String message;
  final int? resultCode;
  final String? reason;

  ServerException({required this.message, this.resultCode, this.reason});

  @override
  String toString() =>
      'ServerException: $message (code: $resultCode, reason: $reason)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class DataParsingException implements Exception {
  final String message;

  DataParsingException(this.message);

  @override
  String toString() => 'DataParsingException: $message';
}

class BleException implements Exception {
  final String message;

  BleException(this.message);

  @override
  String toString() => 'BleException: $message';
}
