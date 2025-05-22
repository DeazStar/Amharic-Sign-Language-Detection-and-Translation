// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your new app widget
import 'app.dart';
// Import the service locator setup
import 'features/theme/presenation/provider/theme_provider.dart';
import 'injection_container.dart' as di; // di as in dependency injection

void main() async {
  // Ensure Flutter bindings are initialized if you have async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service locator
  await di.initServiceLocator();

  runApp(
    ChangeNotifierProvider<ThemeProvider>( // Or just Provider if it's not a ChangeNotifier
      create: (_) => ThemeProvider(
        loadThemeUseCase: di.sl(), 
        saveThemeUseCase: di.sl(),
        loadFontSizeUseCase: di.sl(),
        saveFontSizeUseCase: di.sl(),
      ),    // Create an instance of your ThemeProvider
      child: const CameraAwesomeApp(),   // Your root app widget
    ),
  );
}
