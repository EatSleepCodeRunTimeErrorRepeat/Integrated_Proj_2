// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/utils/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // A GlobalKey to identify the Form and trigger validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers to read the input from text fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Local state to manage password visibility.
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// --- LOGIC METHODS ---

  /// Validates the form and calls the login method in the auth provider.
  Future<void> _login() async {
    // Validate the form fields. If not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Hide the keyboard.
    FocusScope.of(context).unfocus();

    // Use ref.read to call the login function on our AuthProvider.
    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  /// Calls the Google Sign-In method in the auth provider.
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  /// --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    // Use ref.listen to perform side-effects like showing a SnackBar for errors.
    // This doesn't cause the widget to rebuild.
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.peakRed,
          ),
        );
        // Clear the error after showing it so it doesn't pop up again.
        ref.read(authProvider.notifier).clearError();
      }
    });

    // Use ref.watch to get the current state and rebuild the UI when it changes.
    final authState = ref.watch(authProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 48, bottom: bottomInset + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back,',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 36,
                      color: AppTheme.primaryGreen)),
              const SizedBox(height: 4),
              const Text('Glad to see you again!',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(hintText: 'Enter your email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Please enter a valid email'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter your password'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _login,
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                      child: Divider(
                          color: Color(0xFF91959E),
                          thickness: 1,
                          endIndent: 10)),
                  Text('Or Login with',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF6A707C))),
                  Expanded(
                      child: Divider(
                          color: Color(0xFF91959E), thickness: 1, indent: 10)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: AppTheme.lightGrey)),
                child: authState.isLoading
                    ? const SizedBox.shrink()
                    : Image.asset('assets/icons/Google.png', height: 24.0),
              ),
              const SizedBox(height: 36),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
