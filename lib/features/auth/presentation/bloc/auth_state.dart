import 'package:equatable/equatable.dart';
import 'package:wiseman_iot/features/auth/data/models/auth_response_model.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication attempt
class AuthInitial extends AuthState {}

/// State when authentication is in progress
class AuthLoading extends AuthState {}

/// State when authentication succeeds
class AuthSuccess extends AuthState {
  final AuthResponseModel auth;

  AuthSuccess(this.auth);

  @override
  List<Object?> get props => [auth];
}

/// State when authentication fails
class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
