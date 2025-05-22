import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'screens/auth/register_screen.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const RegisterPage(),
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
