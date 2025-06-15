import 'package:flutter/material.dart';

/// This is a stub implementation for mobile that does nothing.
class AdsenseWidget extends StatelessWidget {
  const AdsenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Return an empty container on mobile.
    return const SizedBox.shrink();
  }
}
