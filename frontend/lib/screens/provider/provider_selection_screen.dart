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

  // This function now correctly calls the provider and handles navigation.
  Future<void> _handleProviderSelection(String provider) async {
    // Call the correct provider method which handles the backend call and state update
    final success =
        await ref.read(authProvider.notifier).updateProvider(provider);

    // After the async call, check if the widget is still mounted before navigating.
    if (success && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors from the auth provider to show a snackbar
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
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/icons/Electricity Icon.png',
                height: 70,
                width: 70,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              const Text(
                'Select your\nprovider',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1B5E20),
                ),
              ),
              // Use Expanded to allow the cards to take up vertical space
              // and push the 'Click Here' text to the bottom.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        _buildProviderCard(
                          id: 'MEA',
                          logo: 'assets/images/MEALogo.png',
                          footer: 'Metropolitan Electricity Authority',
                          footerColor: Colors.orange.shade700,
                        ),
                        const SizedBox(height: 24),
                        _buildProviderCard(
                          id: 'PEA',
                          logo: 'assets/images/PEALogo.png',
                          footer: 'Provincial Electricity Authority',
                          footerColor: Colors.purple.shade700,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              // This is the "Don't know" text at the bottom.
              if (!authState.isLoading) // Hide button while loading
                GestureDetector(
                  // You already have a navigation for this, so this is correct
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProviderInfoScreen())),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, top: 10.0),
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
              // Show a loading indicator if the state is loading
              if (authState.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 30.0, top: 20.0),
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  // This is your desired card UI, now integrated correctly.
  Widget _buildProviderCard({
    required String id,
    required String logo,
    required String footer,
    required Color footerColor,
  }) {
    // Use the hoveredProvider state for the selection effect.
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
            height: 220,
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
                    child: Image.asset(logo, fit: BoxFit.contain),
                  ),
                ),
                const Spacer(),
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
