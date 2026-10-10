import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme Palette (Liquid Glass & OLED Deep)
  static const Color darkBg = Color(0xFF07090E);
  static const Color darkCardBg = Color(0x1AFFFFFF); // Glass transparency
  static const Color darkCardBorder = Color(0x33FFFFFF);
  static const Color darkSurface = Color(0xFF0F141C);

  // Light Theme Palette (Frosted Liquid Glass)
  static const Color lightBg = Color(0xFFF4F6FB);
  static const Color lightCardBg = Color(0x99FFFFFF);
  static const Color lightCardBorder = Color(0x4D000000);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Accent & Neon Gradients
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonBlue = Color(0xFF4FACFE);
  static const Color neonPurple = Color(0xFFB06AB3);
  static const Color neonPink = Color(0xFFFF0844);
  static const Color neonOrange = Color(0xFFFFB199);
  static const Color neonGreen = Color(0xFF00E676);

  static const LinearGradient aiGradient = LinearGradient(
    colors: [neonCyan, neonBlue, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient siriOrbGradient = LinearGradient(
    colors: [
      Color(0xFF00D2FF),
      Color(0xFF92FE9D),
      Color(0xFFFF0844),
      Color(0xFFFFB199),
      Color(0xFF7F00FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: darkSurface,
        background: darkBg,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: neonBlue,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      colorScheme: const ColorScheme.light(
        primary: neonBlue,
        secondary: neonPurple,
        surface: lightSurface,
        background: lightBg,
      ),
    );
  }
}
