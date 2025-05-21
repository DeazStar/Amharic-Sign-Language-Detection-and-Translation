// lib/main.dart

import 'package:flutter/material.dart';
// Import your new app widget
import 'app.dart';
// Import the service locator setup
import 'injection_container.dart' as di; // di as in dependency injection

void main() async {
  // Ensure Flutter bindings are initialized if you have async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service locator
  await di.initServiceLocator();

  runApp(const CameraAwesomeApp());
}
