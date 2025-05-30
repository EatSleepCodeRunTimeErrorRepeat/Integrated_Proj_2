import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/selection/provider_selection_screen.dart';
import 'screens/selection/provider_info_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/home/energy_tips_screen.dart'; // Adjust the path as needed

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/landing':
            return MaterialPageRoute(builder: (_) => LandingScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/selection':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final username = args?['username'] ?? 'DefaultUser';
              final email = args?['email'] ?? 'default@example.com';
              return MaterialPageRoute(
                builder: (_) => ProviderSelectionScreen(
                  username: username,
                  email: email,
                ),
              );
            }
          case '/provider-info':
            return MaterialPageRoute(
                builder: (_) => const ProviderInfoScreen());
          case '/home':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final username = args?['username'] ?? 'DefaultUser';
              final email = args?['email'] ?? 'default@example.com';
              final provider = args?['provider'] ?? 'PEA';
              return MaterialPageRoute(
                builder: (_) => HomeScreen(
                  username: username,
                  email: email,
                  provider: provider,
                ),
              );
            }
          case '/profile':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final username = args?['username'] ?? 'DefaultUser';
              final email = args?['email'] ?? 'default@example.com';
              final provider = args?['provider'] ?? 'PEA';
              return MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  username: username,
                  email: email,
                  provider: provider,
                ),
              );
            }
          case '/energy-tips':
            return MaterialPageRoute(builder: (_) => const EnergyTipsScreen());
          default:
            return MaterialPageRoute(builder: (_) => SplashScreen());
        }
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
    );
  }
}
