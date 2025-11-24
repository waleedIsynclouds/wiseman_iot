import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wiseman_iot/core/bloc_observer/app_bloc_observer.dart';
import 'package:wiseman_iot/core/network/wisman.dart';
import 'package:wiseman_iot/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:wiseman_iot/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wiseman_iot/features/auth/domain/usecases/login_usecase.dart';
import 'package:wiseman_iot/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wiseman_iot/features/auth/presentation/pages/login_page.dart';

void main() {
  // Set up global BlocObserver for debugging
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dio = Dio();
    final wisMan = WisMan(dio);
    final authRemoteDataSource = AuthRemoteDataSource(wisMan);
    final authRepository = AuthRepository(authRemoteDataSource);
    final loginUseCase = LoginUseCase(authRepository);

    return MaterialApp(
      title: 'WisMan IoT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => AuthCubit(loginUseCase),
        child: const LoginPage(),
      ),
    );
  }
}
