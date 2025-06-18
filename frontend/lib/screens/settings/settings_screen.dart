// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/settings/about_screen.dart';
import 'package:frontend/screens/settings/change_password_screen.dart';
import 'package:frontend/screens/settings/notifications_screen.dart';
import 'package:frontend/screens/settings/terms_screen.dart';
import 'package:frontend/services/notification_service.dart'; // <-- ADD THIS IMPORT
import 'package:frontend/utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Main',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textGrey)),
          const SizedBox(height: 8),
          _buildSettingItem(
              context, 'Notifications', const NotificationsScreen()),
          _buildSettingItem(
              context, 'Change Password', const ChangePasswordScreen()),
          
          const SizedBox(height: 24),

          // --- THIS IS THE NEW DEBUG SECTION ---
          const Text('Debug Tools',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await NotificationService().showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Test notification sent! Check system tray."),
                    backgroundColor: Colors.green,
                ));
              }
            },
            child: const Text('Send Immediate Test Notification'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            onPressed: () async {
              await NotificationService().printPendingNotifications();
            },
            child: const Text('Print Pending Notifications'),
          ),
          // --- END OF DEBUG SECTION ---

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

  Widget _buildSettingItem(
      BuildContext context, String title, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => destination)),
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