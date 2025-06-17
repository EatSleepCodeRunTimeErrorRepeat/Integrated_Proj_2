import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart';
import 'package:frontend/screens/provider/provider_selection_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      await ref.read(authProvider.notifier).updateLocalAvatar(pickedFile);
    }
  }

  Future<void> _showEditUsernameDialog() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF7F1),
          title: const Text('Change Username',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Username cannot be empty'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.primaryGreen)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(authProvider.notifier)
                      .updateUser(name: nameController.text.trim());
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          return AlertDialog(
            title: const Text('Confirm Password'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: 'Enter your password'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Password is required'
                    : null,
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

                          if (!dialogContext.mounted) return;

                          if (success) {
                            Navigator.of(dialogContext)
                                .pop(); // Close the password dialog
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    const ProviderSelectionScreen())); // Push new screen
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
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ImageProvider displayImage;
    if (authState.localAvatarPath != null) {
      displayImage = FileImage(File(authState.localAvatarPath!));
    } else if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      displayImage = NetworkImage(user.avatarUrl!);
    } else {
      displayImage = const AssetImage('assets/images/avatar.png');
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(radius: 54, backgroundImage: displayImage),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          padding: const EdgeInsets.all(5),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 20, color: Colors.grey),
                          onPressed: _showEditUsernameDialog),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _InfoField(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email),
                  GestureDetector(
                    onTap: _showPasswordDialog,
                    child: _InfoField(
                        icon: Icons.lightbulb_outline,
                        label: 'Electricity Provider',
                        value: user.provider ?? 'Not Set',
                        isEditable: true),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const AuthWrapper()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("Logout",
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditable;

  const _InfoField(
      {required this.icon,
      required this.label,
      required this.value,
      this.isEditable = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8ECF4))),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(value,
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textGrey))),

                // Show edit icon if the field is editable
                if (isEditable)
                  const Icon(Icons.edit, color: AppTheme.textGrey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
