// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the entry page for your sign language detection feature
// Ensure this path is correct based on your project structure.
import 'features/sign_translation/presentation/pages/camera_page.dart';

// Import BLoC for providing it to the widget tree
// Ensure this path is correct.
import 'features/sign_translation/presentation/bloc/sign_translation_bloc.dart';

// Import the service locator instance (sl)
// Ensure this path is correct.
import 'injection_container.dart'; 

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider is used to provide one or more BLoCs to the widget tree.
    return MultiBlocProvider(
      providers: [
        // Provide SignTranslationBloc using the service locator (sl).
        // sl<SignTranslationBloc>() retrieves the instance registered in injection_container.dart.
        BlocProvider<SignTranslationBloc>(
          create: (context) => sl<SignTranslationBloc>(),
        ),
        // If you have other BLoCs for different features, you can provide them here as well.
        // For example:
        // BlocProvider<AnotherFeatureBloc>(
        //   create: (context) => sl<AnotherFeatureBloc>(),
        // ),
      ],
      child: const MaterialApp(
        title: 'Sign Language App', // You can customize the app title.
        // The initial screen of your application.
        // CameraPage is expected to be the entry point for capturing images/videos.
        home: CameraPage(), 
        // You can also define theme data, routes, etc., for your MaterialApp here.
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        //   // Define other theme properties.
        // ),
      ),
    );
  }
}
