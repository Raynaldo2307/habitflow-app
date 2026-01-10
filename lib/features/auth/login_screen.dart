import 'package:flutter/material.dart';
import 'package:habitflow/routes/app_routes.dart';
import 'package:habitflow/features/auth/services/auth_service.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Email',
                      ),
                      onChanged: (value) => email = value,
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      focusNode: _passwordFocus,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Password',
                      ),
                      onChanged: (value) => password = value,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Min 6 characters',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final error = await AuthService().loginWithEmail(
                            email,
                            password,
                          );

                          if (!context.mounted) return;

                          if (error == null) {
                            // Login successful
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.mainLayout,
                            );
                          } else {
                            // Show error
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                    // 👇 Add this right after
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.register,
                        );
                      },
                      child: const Text("Don't have an account? Register here"),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.forgotPassword,
                        );
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
