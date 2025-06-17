// lib/screens/auth/auth_wrapper.dart

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
    // Watch the authProvider for state changes.
    final authState = ref.watch(authProvider);

    // While the provider is checking for a token, show a loading indicator.
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // -- Decision Logic --

    // If the user is authenticated...
    if (authState.isAuthenticated) {
      // ...and they have selected a provider, show the main app screen.
      if (authState.user?.provider != null &&
          authState.user!.provider!.isNotEmpty) {
        return const MainScreen();
      } else {
        // ...but they haven't selected a provider, force them to the selection screen.
        return const ProviderSelectionScreen();
      }
    }
    // If the user is not authenticated, show the login screen.
    else {
      return const LoginScreen();
    }
  }
}
