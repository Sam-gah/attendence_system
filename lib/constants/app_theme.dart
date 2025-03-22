import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color secondaryLight = Color(0xFF03A9F4);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color textLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondaryDark = Color(0xFF0288D1);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Text Styles - Light
  static const TextStyle heading1Light = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textLight,
  );

  static const TextStyle heading2Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textLight,
  );

  static const TextStyle heading3Light = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textLight,
  );

  static const TextStyle bodyTextLight = TextStyle(
    fontSize: 16,
    color: textLight,
  );

  static const TextStyle captionLight = TextStyle(
    fontSize: 14,
    color: textSecondaryLight,
  );

  // Text Styles - Dark
  static const TextStyle heading1Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle heading2Dark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle heading3Dark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle bodyTextDark = TextStyle(
    fontSize: 16,
    color: textDark,
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 14,
    color: textSecondaryDark,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: surfaceLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: textDark,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryLight,
      disabledColor: Colors.grey[300],
      labelStyle: const TextStyle(color: textLight),
      secondaryLabelStyle: const TextStyle(color: textDark),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryLight),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textDark,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primaryDark,
      disabledColor: Colors.grey[800],
      labelStyle: const TextStyle(color: textDark),
      secondaryLabelStyle: const TextStyle(color: textLight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryDark),
      ),
    ),
  );
}
