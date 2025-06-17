// lib/screens/settings/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/app_theme.dart';

// Convert to a ConsumerWidget to access providers
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authProvider to get the user's current settings
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Get the current notification setting from the user model, with a fallback
    final bool enableNotifications =
        authState.user?.notificationsEnabled ?? true;
    final bool enablePeakHourAlerts = authState.user?.peakHourAlertsEnabled ??
        true; // NEW: Read specific setting

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('General',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey)),
            const SizedBox(height: 12),
            _buildNotificationToggle(
              title: 'Enable Notifications',
              description: 'Turn on or off all notifications from the app.',
              value: enableNotifications, // Use value from provider
              onChanged: (val) {
                // Call the provider method to update the backend
                authNotifier.updateNotificationPreference(val);
              },
            ),
            const Divider(height: 30),
            const Text('Alerts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey)),
            const SizedBox(height: 12),
            // This toggle is now dependent on the main one
            _buildNotificationToggle(
              title: 'Peak Hour Alerts',
              description:
                  'Receive reminders when peak hours are about to begin or end.',
              value:
                  enablePeakHourAlerts, // NEW: Use specific peak hour setting
              onChanged:
                  enableNotifications // Only allow toggling if master is ON
                      ? (val) {
                          authNotifier.updatePeakHourAlertPreference(
                              val); // NEW: Call specific update method
                        }
                      : null, // Disable if master is off
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged, // Made nullable
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description,
                  style:
                      const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged, // Will be null if master is off
          activeColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }
}
