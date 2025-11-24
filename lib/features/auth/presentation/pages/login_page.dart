import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wiseman_iot/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:wiseman_iot/features/auth/presentation/bloc/auth_state.dart';
import 'package:wiseman_iot/features/auth/presentation/pages/home_page.dart';

/// Login page for WisMan authentication
/// Allows users to enter account credentials and authenticate
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values for the text fields
    _accountNameController.text = "Waleed";
    _passwordController.text = "12345678";
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        accountName: _accountNameController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WisMan Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to home page on successful login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomePage(auth: state.auth)),
            );
          } else if (state is AuthFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or title
                    const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Welcome to WisMan IoT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Account Name Field
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      enabled: state is! AuthLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field (MD5)
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password (MD5)',
                        prefixIcon: Icon(Icons.key),
                        border: OutlineInputBorder(),
                        helperText: 'Enter MD5 hashed password',
                      ),
                      obscureText: true,
                      enabled: state is! AuthLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 16),

                    // Helper text
                    const Text(
                      'Example:\nAccount: huixianggongyu-test\nPassword: E10ADC3949BA59ABBE56E057F20F883E',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
