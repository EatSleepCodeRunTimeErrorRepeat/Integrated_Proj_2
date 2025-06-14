// lib/screens/profile/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/provider/provider_selection_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/widgets/top_navbar.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool fromSettings;
  const ProfileScreen({super.key, this.fromSettings = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      // TODO: Call backend to upload image
    }
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // FIX: Awaited the dialog and then checked if the context is still mounted.
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(builder: (context, ref, child) {
          final authState = ref.watch(authProvider);

          ref.listen<AuthState>(authProvider, (previous, next) {
            if (next.error != null && previous?.error != next.error) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                content: Text(next.error!),
                backgroundColor: AppTheme.peakRed,
              ));
              ref.read(authProvider.notifier).clearError();
            }
          });

          return AlertDialog(
            title: const Text('Confirm Password'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Enter your password'),
                validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final success = await ref
                              .read(authProvider.notifier)
                              .verifyPassword(passwordController.text);
                          // FIX: Check for mounted context before using it.
                          if (!dialogContext.mounted) return;
                          if (success) {
                            Navigator.of(dialogContext).pop(); // Close dialog
                            Navigator.push(dialogContext, MaterialPageRoute(
                                builder: (_) => const ProviderSelectionScreen()));
                          }
                        }
                      },
                child: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found.")));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: TopNavBar(
        showBackButton: widget.fromSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : const AssetImage('assets/images/avatar.png')
                          as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 40),
            _InfoField(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            GestureDetector(
              onTap: _showPasswordDialog,
              child: _InfoField(
                icon: Icons.lightbulb_outline,
                label: 'Electricity Provider',
                value: user.provider ?? 'Not Set',
                isEditable: true,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _showPasswordDialog,
                child: const Text('Change Provider'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OutlinedButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.peakRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Logout",
                    style: TextStyle(color: AppTheme.peakRed, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditable;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8ECF4)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textGrey)),
                ),
                if (isEditable)
                  const Icon(Icons.arrow_forward_ios,
                      color: AppTheme.textGrey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}