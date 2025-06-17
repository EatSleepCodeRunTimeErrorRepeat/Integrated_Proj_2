// lib/utils/constants.dart
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

// --- DEVELOPMENT SERVER CONFIGURATION ---

// Use this IP for the Android Emulator ONLY.
const String _androidEmulatorIp = '10.0.2.2';

// Use this IP for testing on a PHYSICAL phone or a WEB BROWSER.
// Find this by typing 'ipconfig' (Windows) or checking System Settings (Mac).
// Make sure your phone and computer are on the same Wi-Fi network.
const String _localNetworkIp = '192.168.1.37'; // <-- REPLACE THIS

// The port backend is running on from .env file.
const String _port = '8000';

// --- PRODUCTION SERVER CONFIGURATION (for later) ---
const String _productionUrl = 'https://your-production-app-url.com';

// --- API Base URL Getter ---

// This logic automatically selects the correct URL.
String get apiBaseUrl {
  if (kDebugMode) {
    // When running in debug mode...
    if (kIsWeb) {
      // If the app is running on the web, use the local network IP.
      return 'http://$_localNetworkIp:$_port/api';
    }
    // For mobile, you can switch based on your testing device.
    // For now, we will default to the local network IP for physical devices.
    // To test on an emulator, change _localNetworkIp to _androidEmulatorIp.
    return 'http://$_localNetworkIp:$_port/api';
  } else {
    // For a release build, it will use your future production URL.
    return '$_productionUrl/api';
  }
}
