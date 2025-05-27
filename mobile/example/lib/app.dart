// lib/app.dart

import 'package:camera_app/app_theme.dart';
import 'package:camera_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:camera_app/features/sign_translation/presentation/pages/main_navigation_page.dart';
import 'package:camera_app/features/text_to_speech/presentation/bloc/tts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// Import the entry page for your sign language detection feature
// Ensure this path is correct based on your project structure.
import 'features/feedback/presentation/bloc/bloc/feedback_bloc.dart';
import 'features/sign_translation/presentation/pages/camera_page.dart';

// Import BLoC for providing it to the widget tree
// Ensure this path is correct.
import 'features/sign_translation/presentation/bloc/sign_translation_bloc.dart';

// Import the service locator instance (sl)
// Ensure this path is correct.
import 'features/theme/presenation/provider/theme_provider.dart';
import 'injection_container.dart'; 

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MultiBlocProvider(
      providers: [
        // Provide SignTranslationBloc using the service locator (sl).
        // sl<SignTranslationBloc>() retrieves the instance registered in injection_container.dart.
        BlocProvider<SignTranslationBloc>(
          create: (context) => sl<SignTranslationBloc>(),
        ),
        
         BlocProvider<FeedbackBloc>(
          create: (_) => sl<FeedbackBloc>(),
        ),
        BlocProvider<TtsBloc>(
          create: (_) => sl<TtsBloc>(),
        ),
          
      ],
      child: MaterialApp(
        title: 'Sign Language App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(themeProvider.fontSize),
        darkTheme: AppTheme.dark(themeProvider.fontSize),
        themeMode: themeProvider.themeMode,
        
        home: OnboardingPage(), 
        // You can also define theme data, routes, etc., for your MaterialApp here.
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        //   // Define other theme properties.
        // ),
      ),
    );
  }
}
