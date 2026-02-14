import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Logged in as: ${state.user.username}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    if (state.user.email != null)
                      Text(
                        'Email: ${state.user.email}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
