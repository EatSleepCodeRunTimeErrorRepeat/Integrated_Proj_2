import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool enableNotifications = false;
  bool peakHourAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green top bar with back button
          Container(
            height: 76,
            width: double.infinity,
            color: const Color(0xFF366D34),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 43),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Main "Notifications" title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600, // Medium (weight 500)
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // New Main section label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Main',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500, // Medium
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Enable Notifications toggle
          _buildNotificationToggle(
            context,
            title: 'Enable Notifications',
            description: 'Turn on or off all notifications including updates.',
            value: enableNotifications,
            onChanged: (val) {
              setState(() {
                enableNotifications = val;
              });
            },
          ),

          const SizedBox(height: 20),

          // Peak Hour Alerts toggle
          _buildNotificationToggle(
            context,
            title: 'Peak Hour Alerts',
            description:
                'Receive notifications when peak hours are about to begin or end.',
            value: peakHourAlerts,
            onChanged: (val) {
              setState(() {
                peakHourAlerts = val;
              });
            },
          ),

          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context, {
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texts Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500, // Medium 15 for items
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300, // Light
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Smaller toggle switch with no outline & white thumb
          Transform.scale(
            scale: 0.85,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF2196F3),
                activeTrackColor: const Color(0xFF90CAF9),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
