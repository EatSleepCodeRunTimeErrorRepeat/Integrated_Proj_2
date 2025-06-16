import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/provider/provider_info_screen.dart';

class ProviderSelectionScreen extends ConsumerStatefulWidget {
  const ProviderSelectionScreen({super.key});

  @override
  ConsumerState<ProviderSelectionScreen> createState() =>
      _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState
    extends ConsumerState<ProviderSelectionScreen> {
  String? hoveredProvider;

  Future<void> _handleProviderSelection(String provider) async {
    final success =
        await ref.read(authProvider.notifier).updateProvider(provider);

    if (success && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Move content up
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Reduce space at the top
              Center(
                child: Image.asset(
                  'assets/icons/Electricity Icon.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(
                width: 300,
                height: 100,
                child: Text(
                  'Select your\nprovider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(
                  height: 30), // Reduce space between header and cards
              buildProviderCard(
                id: 'MEA',
                logo: 'assets/images/MEALogo.png',
                footer: 'Metropolitan Electricity Authority',
                footerColor: Colors.orange.shade700,
              ),
              const SizedBox(
                  height:
                      40), // Reduce space between the first and second cards
              buildProviderCard(
                id: 'PEA',
                logo: 'assets/images/PEALogo.png',
                footer: 'Provincial Electricity Authority',
                footerColor: Colors.purple.shade700,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
        child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProviderInfoScreen())),
          child: Text.rich(
            TextSpan(
              text: "Don't know your provider? ",
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: "Click Here",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProviderCard({
    required String id,
    required String logo,
    required String footer,
    required Color footerColor,
  }) {
    final bool isSelected = hoveredProvider == id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hoveredProvider = id;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredProvider = null;
        });
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => _handleProviderSelection(id),
          child: Container(
            width: 200,
            height: 230,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F2E5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? footerColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      logo,
                      fit: BoxFit.contain,
                      height: 120, // Adjusted logo height
                      width: 120, // Adjusted logo width
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 170,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: footerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    footer,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
