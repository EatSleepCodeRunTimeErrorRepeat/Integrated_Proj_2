import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: Stack(
        children: [
          Column(
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
                      onTap: () => Navigator.pushNamed(context, '/home'),
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

              // Settings title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, // SemiBold
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main section label
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

              _buildSettingItem(context, 'Edit profile', '/profile'),
              _buildSettingItem(context, 'Notifications', '/notifications'),
              _buildSettingItem(context, 'Change Password', '/change-password'),

              const SizedBox(height: 24),

              // More section label
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'More',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500, // Medium
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingItem(context, 'About us', '/about-us'),
              _buildSettingItem(context, 'Terms and conditions', '/terms'),

              // Add bottom padding to avoid overlap
              const SizedBox(height: 140),
            ],
          ),

          // Logout button positioned at bottom (optional, remove if you want)
          Positioned(
            left: 34,
            top: 672,
            right: 34,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Add logout logic here
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF366D34)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Color(0xFF366D34),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, String title, String routeName) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400, // Regular
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            Image.asset(
              'assets/icons/navigationarrow.png',
              width: 24,
              height: 24,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
