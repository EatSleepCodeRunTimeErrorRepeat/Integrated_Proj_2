// lib/utils/constants.dart
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:io' show Platform;

String get apiBaseUrl {
  if (kDebugMode) {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    // For mobile emulators/simulators
    try {
      if (Platform.isAndroid) {
        // Android Emulator
        return 'http://10.0.2.2:8000/api';
      } else if (Platform.isIOS) {
        // iOS Simulator
        return 'http://localhost:8000/api';
      }
    } catch (e) {
      // Fallback for other desktop platforms if needed
      return 'http://localhost:8000/api';
    }
  }
  // Default for a release build
  return 'https://your_production_url.com/api';
}
