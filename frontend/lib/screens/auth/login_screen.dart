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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.peakRed,
          ),
        );
        // It's good practice to clear the error after showing it
        ref.read(authProvider.notifier).clearError();
      }
    });

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

              // "Or Login with" text with dashed lines
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color.fromARGB(255, 145, 149, 158),
                      thickness: 1,
                      endIndent: 10, // Adjust space before the text
                    ),
                  ),
                  const Text(
                    'Or Login with',
                    style: TextStyle(
                      fontFamily:
                          'Urbanist', // Ensure this font is in your pubspec.yaml
                      fontWeight: FontWeight.w600, // Semibold
                      fontSize: 14, // Font size 14
                      color: Color(0xFF6A707C), // Color #6A707C
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 10, // Adjust space after the text
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Google sign-in button
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authProvider.notifier).signInWithGoogle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: AppTheme.lightGrey),
                  padding: const EdgeInsets.all(16.0),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Image.asset('assets/icons/Google.png', height: 24.0),
              ),
              const SizedBox(height: 36),
              Center(
                child: GestureDetector(
                  // FIX: Changed to Navigator.push to allow returning to the login screen
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.primaryGreen,
                          ),
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
