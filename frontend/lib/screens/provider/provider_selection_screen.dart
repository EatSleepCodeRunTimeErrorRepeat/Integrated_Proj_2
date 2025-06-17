import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/provider/provider_info_screen.dart';
import 'package:frontend/utils/app_theme.dart';

class ProviderSelectionScreen extends ConsumerStatefulWidget {
  const ProviderSelectionScreen({super.key});

  @override
  ConsumerState<ProviderSelectionScreen> createState() =>
      _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState
    extends ConsumerState<ProviderSelectionScreen> {
  // State variable to track the highlighted provider
  String? _selectedProviderId;

  void _handleProviderTap(String providerId) {
    // If the user taps the already selected card, confirm the choice.
    if (_selectedProviderId == providerId) {
      _confirmProviderSelection(providerId);
    } else {
      // Otherwise, just highlight the new selection.
      setState(() {
        _selectedProviderId = providerId;
      });
    }
  }

  Future<void> _confirmProviderSelection(String newProvider) async {
    final currentProvider = ref.read(authProvider).user?.provider;

    if (newProvider == currentProvider) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final success =
        await ref.read(authProvider.notifier).updateProvider(newProvider);

    if (success && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Electricity Provider'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textBlack,
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        // FIX: Wrap the Column in a SingleChildScrollView to ensure it never overflows
        // on smaller screens.
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                buildProviderCard(
                  id: 'MEA',
                  logo: 'assets/images/MEALogo.png',
                  footer: 'Metropolitan Electricity Authority',
                  footerColor: Colors.orange.shade700,
                ),
                const SizedBox(height: 40),
                buildProviderCard(
                  id: 'PEA',
                  logo: 'assets/images/PEALogo.png',
                  footer: 'Provincial Electricity Authority',
                  footerColor: Colors.purple.shade700,
                ),
                const SizedBox(height: 60),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProviderInfoScreen())),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't know your provider? ",
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                          color: Colors.black),
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
    final bool isSelected = _selectedProviderId == id;

    return GestureDetector(
      onTap: () => _handleProviderTap(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 250,
        height: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F2E5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? footerColor : Colors.grey.shade300,
            width: isSelected ? 4.0 : 2.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: footerColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              )
            else
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(logo, fit: BoxFit.contain),
              ),
            ),
            Container(
              width: 200,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: footerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                footer,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
