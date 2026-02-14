import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'blocs/auth/auth_bloc.dart';
import 'api/api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ApiClient(),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(apiClient: context.read<ApiClient>())..add(AppStarted()),
        child: CalendarControllerProvider(
          controller: EventController(),
          child: MaterialApp(
            title: 'Is It Open',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const HomeScreen();
                }
                if (state is AuthUnauthenticated || state is AuthFailure) {
                  return const LoginScreen();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
