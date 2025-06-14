import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/provider/provider_selection_screen.dart';
import 'package:frontend/widgets/main_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isAuthenticated) {
      if (authState.user?.provider != null && authState.user!.provider!.isNotEmpty) {
        return const MainScreen();
      } else {
        return const ProviderSelectionScreen();
      }
    } else {
      return const LoginScreen();
    }
  }
}