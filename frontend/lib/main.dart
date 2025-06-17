import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/screens/auth/splash_screen.dart';
import 'package:frontend/services/notification_service.dart'; // Import the service
import 'package:frontend/utils/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Do not initialize notifications or ads for the web version.
  if (!kIsWeb) {
    // Initialize our Notification Service
    await NotificationService().init();
    // Request permissions right at the start (optional, can be moved elsewhere)
    await NotificationService().requestPermissions();
    // Initialize Mobile Ads
    await MobileAds.instance.initialize();
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('app_data');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeakSmart TH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
