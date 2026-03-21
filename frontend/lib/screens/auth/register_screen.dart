import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../components/shared/glass_card.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF0D47A1),
                Color(0xFF01579B),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Join Us',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to get started',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Register',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Username',
                                  Icons.person_outline,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Email (Optional)',
                                  Icons.email_outlined,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration(
                                  'Password',
                                  Icons.lock_outline,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                  return ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                          RegisterRequested(
                                            username: _usernameController.text,
                                            password: _passwordController.text,
                                            email: _emailController.text,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent),
    );
  }
}
