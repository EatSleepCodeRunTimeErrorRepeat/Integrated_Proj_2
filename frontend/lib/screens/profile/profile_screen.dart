import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/provider/provider_selection_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/widgets/top_navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/widgets/bottom_nav.dart'; // Import your BottomNav

// Import the screens for navigation
import 'package:frontend/screens/schedule/schedule_screen.dart'; // Import ScheduleScreen
import 'package:frontend/screens/home/home_screen.dart'; // Import HomeScreen

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

    await showDialog<void>(
      // Password change dialog
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
            backgroundColor:
                const Color(0xFFF8F2E5), // Background color for the container
            title: const Text(
              'Confirm Password',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            content: Form(
              key: formKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12), // Content padding
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2), // Border with more visibility
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2), // More prominent border color
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primaryGreen),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Password is required'
                      : null,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppTheme
                          .primaryGreen), // Cancel button in AppTheme.green
                ),
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
                            Navigator.of(dialogContext).pop();
                            Navigator.push(
                                dialogContext,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ProviderSelectionScreen()));
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 40), // Smaller verify button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
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
                      icon: Icons.lightbulb_outline, // Light bulb icon
                      label: 'Electricity Provider',
                      value: user.provider ?? 'Not Set',
                      isEditable: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(
                    color: AppTheme.primaryGreen), // Use AppTheme color
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Logout",
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 16)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2, // ProfileScreen index
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            // ProfileScreen (no action required)
          }
        },
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
                Icon(icon, color: Colors.grey.shade600), // Light bulb icon here
                const SizedBox(width: 10),
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textGrey)),
                ),
                if (isEditable)
                  const Icon(Icons.edit,
                      color: AppTheme.textGrey,
                      size: 16), // Pencil icon for edit
              ],
            ),
          ),
        ],
      ),
    );
  }
}
