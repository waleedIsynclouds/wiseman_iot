import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Used to represent errors in a structured way following Clean Architecture
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure related to server communication
class ServerFailure extends Failure {
  final int? resultCode;
  final String? reason;

  const ServerFailure({required String message, this.resultCode, this.reason})
    : super(message);

  @override
  List<Object> get props => [message, resultCode ?? 0, reason ?? ''];
}

/// Failure related to network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure related to data parsing
class DataParsingFailure extends Failure {
  const DataParsingFailure(super.message);
}

/// Failure related to BLE operations
class BleFailure extends Failure {
  const BleFailure(super.message);
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
