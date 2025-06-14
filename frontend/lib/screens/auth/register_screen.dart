// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/utils/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref.read(authProvider.notifier).clearError();
      
      final success = await ref.read(authProvider.notifier).register(
        _nameController.text.trim(), 
        _emailController.text.trim(), 
        _passwordController.text.trim()
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: AppTheme.offPeakGreen,
        ));
        // FIX: Navigate to Login screen instead of pop() to avoid going to an empty screen
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: AppTheme.peakRed));
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);
    
    // FIX: Added a Scaffold with an AppBar to provide a back button
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        // This makes the back button visible
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Account', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 24, color: AppTheme.primaryGreen)),
                const SizedBox(height: 6),
                const Text('Register to get started!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 24),
                TextFormField(controller: _nameController, decoration: const InputDecoration(hintText: 'Username'), validator: (v) => (v == null || v.isEmpty) ? 'Please enter a username' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(hintText: 'Password', suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _confirmPassController, obscureText: _obscureConfirmPassword, decoration: InputDecoration(hintText: 'Confirm Password', suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white)) : const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
