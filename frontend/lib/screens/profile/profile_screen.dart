import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart';
import 'package:frontend/screens/provider/provider_selection_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/widgets/top_navbar.dart';
import 'package:image_picker/image_picker.dart';
// ADD THIS IMPORT for local storage
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool fromSettings;
  const ProfileScreen({super.key, this.fromSettings = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // This holds the preview of a just-picked image
  File? _avatarImage;
  // This will hold the path of the image saved to local storage
  String? _savedAvatarPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load the saved avatar path when the screen is first loaded
    _loadSavedAvatar();
  }

  /// Loads the image path from the device's local storage.
  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    // We use a user-specific key to avoid showing one user's picture for another
    final userId = ref.read(authProvider).user?.id;
    if (userId != null && prefs.containsKey('avatar_path_$userId')) {
      setState(() {
        _savedAvatarPath = prefs.getString('avatar_path_$userId');
      });
    }
  }

  /// Lets the user pick an image and saves its path locally.
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      // Show a preview of the image immediately
      setState(() {
        _avatarImage = File(pickedFile.path);
        _savedAvatarPath =
            null; // Clear old saved path to prioritize new preview
      });

      // --- SIMPLER SOLUTION: Save the file path locally ---
      final prefs = await SharedPreferences.getInstance();
      final userId = ref.read(authProvider).user?.id;
      if (userId != null) {
        await prefs.setString('avatar_path_$userId', pickedFile.path);
      }
    }
  }

  // ... (The _showEditUsernameDialog and _showPasswordDialog methods remain unchanged)
  Future<void> _showEditUsernameDialog() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New Username'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Username cannot be empty'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(authProvider.notifier)
                      .updateUser(name: nameController.text.trim());
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found.")));
    }

    // Determine which image to show based on a clear priority
    ImageProvider displayImage;
    if (_avatarImage != null) {
      // 1. Show the newly picked image file
      displayImage = FileImage(_avatarImage!);
    } else if (_savedAvatarPath != null) {
      // 2. Show the image from the saved local path
      displayImage = FileImage(File(_savedAvatarPath!));
    } else if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      // 3. Show the synced Google/backend image URL
      displayImage = NetworkImage(user.avatarUrl!);
    } else {
      // 4. Fallback to the default asset image
      displayImage = const AssetImage('assets/images/avatar.png');
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: TopNavBar(showBackButton: widget.fromSettings),
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
                        backgroundImage:
                            displayImage, // Use the determined image
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: Colors.grey),
                        onPressed: _showEditUsernameDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _InfoField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  GestureDetector(
                    onTap: () {}, //_showPasswordDialog,
                    child: _InfoField(
                      icon: Icons.lightbulb_outline,
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
              onPressed: () async {
                // First, await the logout process from the provider
                await ref.read(authProvider.notifier).logout();
                // After logout, navigate to the AuthWrapper and clear all previous screens.
                // This ensures a clean state and navigates the user to the LoginScreen.
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
                    borderRadius: BorderRadius.circular(12)),
              ),
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
                  const Icon(Icons.edit, color: AppTheme.textGrey, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
