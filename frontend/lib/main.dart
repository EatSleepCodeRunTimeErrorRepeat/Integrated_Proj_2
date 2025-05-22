import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart'; // 👈 Add login screen
import 'screens/auth/splash_screen.dart'; // 👈 Add splash screen
import 'screens/auth/landing_screen.dart'; // 👈 Add landing screen
import 'screens/selection/provider_selection_screen.dart';
import 'screens/selection/provider_info_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeakSmart',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start at splash
      routes: {
        '/': (context) => SplashScreen(),
        '/landing': (context) => LandingScreen(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginScreen(),
        '/selection': (context) => ProviderSelectionScreen(),
        '/provider-info': (context) => const ProviderInfoScreen(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
    );
  }
}
