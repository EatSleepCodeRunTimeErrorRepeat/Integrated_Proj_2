import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF366D34);
  static const Color background = Color(0xFFFBF8F0);
  static const Color peakRed = Color(0xFFFF5B52);
  static const Color offPeakGreen = Color(0xFF4CAF50);
  static const Color lightGrey = Color(0xFFF7F8F9);
  static const Color darkGrey = Color(0xFF8391A1);
  static const Color textBlack = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF6A707C);
  static const Color adGrey = Color(0xFFABABAB);
  static const Color peakRedBackground = Color(0xFFFDEBEB);
  static const Color offPeakGreenBackground = Color(0xFFEBF9F3);
  static const Color holidayBlue = Color(0xFF4A90E2);

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primaryGreen,
    fontFamily: 'Inter',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: textBlack),
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: textBlack,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: darkGrey,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
