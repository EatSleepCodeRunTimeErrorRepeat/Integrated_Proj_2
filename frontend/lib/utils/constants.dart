import 'package:flutter/foundation.dart' show kDebugMode;

// --- DEVELOPMENT CONFIGURATION ---
// IMPORTANT: Replace this with your computer's current Local IP address.
// This is the only line you or your teammates will ever need to change.
const String _localDevIp = '192.168.1.35';

// The port your backend is running on.
const String _port = '8000';

// --- PRODUCTION CONFIGURATION ---
const String _productionUrl = 'https://your-production-app-url.com';

// This getter automatically selects the correct URL based on the build mode.
String get apiBaseUrl {
  if (kDebugMode) {
    // For local development on any device (web, mobile) on the same Wi-Fi.
    return 'http://$_localDevIp:$_port/api';
  } else {
    // For a release build.
    return '$_productionUrl/api';
  }
}
