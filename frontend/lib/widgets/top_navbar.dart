import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/navigation_provider.dart';
import 'package:frontend/screens/tips/energy_tips_screen.dart';

class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current page provider.
    final currentPage = ref.watch(mainScreenPageProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF356C33), // Green background
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Conditionally show a Back button or the Settings icon.
          if (currentPage == AppScreen.settings)
            // Show a Back button when on the settings page.
            GestureDetector(
              onTap: () {
                // Tapping "Back" changes the state back to the profile screen.
                ref.read(mainScreenPageProvider.notifier).state =
                    AppScreen.profile;
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child:
                    Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
              ),
            )
          else
            // Show the Settings icon on all other main pages.
            GestureDetector(
              onTap: () {
                // Tapping "Settings" changes the state to show the settings page.
                ref.read(mainScreenPageProvider.notifier).state =
                    AppScreen.settings;
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Image.asset(
                  'assets/icons/settings.png',
                  height: 47, // Adjusted to match previous size
                  width: 47, // Adjusted to match previous size
                ),
              ),
            ),
          const Spacer(),
          // Energy Tips Icon with navigation logic
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      EnergyTipsScreen(selectedDate: DateTime.now())),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 12.0), // Move down by 12 pixels
              child: Image.asset(
                'assets/icons/EnergyTipsEdit.png',
                height: 43, // Adjusted size to match previous one
                width: 43, // Adjusted size to match previous one
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(90); // Adjusted height for the navbar
}
