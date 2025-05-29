import 'package:flutter/material.dart';

class ProviderSelectionScreen extends StatefulWidget {
  final String username;
  final String email;

  const ProviderSelectionScreen({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  _ProviderSelectionScreenState createState() =>
      _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends State<ProviderSelectionScreen> {
  String? selectedProvider;

  void selectProvider(String provider) {
    setState(() {
      selectedProvider = provider;
    });

    // Navigate to home screen and pass username, email, and selected provider
    Navigator.pushNamed(
      context,
      '/home',
      arguments: {
        'username': widget.username,
        'email': widget.email,
        'provider': provider,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 40),
                  buildProviderCard(
                    id: 'MEA',
                    logo: 'assets/images/MEALogo.png',
                    footer: 'Metropolitan Electricity Authority',
                    footerColor: Colors.orange,
                  ),
                  const SizedBox(height: 50),
                  buildProviderCard(
                    id: 'PEA',
                    logo: 'assets/images/PEALogo.png',
                    footer: 'Provincial Electricity Authority',
                    footerColor: Colors.purple,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/provider-info'),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't know your provider? ",
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500, // Medium
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
            ),
          ],
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
    final bool isSelected = selectedProvider == id;

    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => selectProvider(id),
        child: Container(
          width: 200,
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F2E5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? footerColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 127,
                width: 125,
                child: Image.asset(logo, fit: BoxFit.contain),
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
    );
  }
}
