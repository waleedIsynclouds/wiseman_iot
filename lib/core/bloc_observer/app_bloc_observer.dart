import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

/// Global BlocObserver to monitor all Bloc/Cubit state changes and errors
/// Used for debugging and logging throughout the application
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    developer.log('onCreate -- ${bloc.runtimeType}', name: 'BlocObserver');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log(
      'onChange -- ${bloc.runtimeType}\n'
      'Current State: ${change.currentState}\n'
      'Next State: ${change.nextState}',
      name: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'onError -- ${bloc.runtimeType}\n'
      'Error: $error\n'
      'StackTrace: $stackTrace',
      name: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    developer.log('onClose -- ${bloc.runtimeType}', name: 'BlocObserver');
  }
}
