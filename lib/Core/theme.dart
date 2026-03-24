import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgTop = Color(0xFF0D1B2A);     // dark blue
  static const Color bgMid = Color(0xFF1B263B);     // deeper blue
  static const Color bgBottom = Color(0xFF000000);  // black

  static const Color card = Color(0xFF111111);
  static const Color field = Color(0xFF1C1C1C);

  static ThemeData darkBlueTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Keep transparent so gradient background can show behind Scaffold
    scaffoldBackgroundColor: Colors.transparent,

    // ✅ Works in all versions
    cardColor: card,

    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.lightBlueAccent,
      surface: card,
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: field,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.blueAccent,
      suffixIconColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
  );
}