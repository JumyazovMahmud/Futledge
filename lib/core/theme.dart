import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
}

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF5722),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: const Color(0xFF1E1E1E),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFFF5722),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
    ),
  );
}