import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(double fontSize) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black, fontSize: fontSize),
        bodyLarge: TextStyle(color: Colors.black, fontSize: fontSize + 2),
        titleLarge: TextStyle(color: Colors.black, fontSize: fontSize + 4),
        // Add other styles as needed
      ),
    );
  }

  static ThemeData dark(double fontSize) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.white, fontSize: fontSize),
        bodyLarge: TextStyle(color: Colors.white, fontSize: fontSize + 2),
        titleLarge: TextStyle(color: Colors.white, fontSize: fontSize + 4),
      ),
    );
  }
}
