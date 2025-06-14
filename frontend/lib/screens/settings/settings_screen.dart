// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/settings/about_screen.dart';
import 'package:frontend/screens/settings/change_password_screen.dart';
import 'package:frontend/screens/settings/notifications_screen.dart';
import 'package:frontend/screens/settings/terms_screen.dart';
import 'package:frontend/utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // The default back button is used here, which correctly pops the screen
        // off the navigation stack, returning to the previous page (home or profile).
        leading: const BackButton(color: AppTheme.textBlack),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Main',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          // Pass the fromSettings flag to the ProfileScreen
          _buildSettingItem(
              context, 'Edit profile', const ProfileScreen(fromSettings: true)),
          _buildSettingItem(context, 'Notifications', const NotificationsScreen()),
          _buildSettingItem(
              context, 'Change Password', const ChangePasswordScreen()),
          const SizedBox(height: 24),
          const Text('More',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          _buildSettingItem(context, 'About us', const AboutUsScreen()),
          _buildSettingItem(
              context, 'Terms and conditions', const TermsAndConditionsScreen()),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, Widget destination) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            Image.asset('assets/icons/navigationarrow.png',
                width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
