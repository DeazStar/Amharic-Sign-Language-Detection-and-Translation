// lib/injection_container.dart  OR  lib/core/di/injection_container.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Core
import 'core/network/network_info.dart';

// Features - Sign Translation
// Data Sources
import 'features/sign_translation/data/datasources/sign_translation_remote_datasource.dart';
import 'features/sign_translation/data/datasources/sign_translation_remote_datasource_impl.dart';
// Repositories
import 'features/sign_translation/domain/repositories/sign_translation_repository.dart';
import 'features/sign_translation/data/repositories/sign_translation_repository_impl.dart';
// Use Cases
import 'features/sign_translation/domain/usecases/translate_sign_usecase.dart';
// BLoC
import 'features/sign_translation/presentation/bloc/sign_translation_bloc.dart';

import 'package:camera_app/features/feedback/data/data_source/feedback_datasource.dart';
import 'package:camera_app/features/feedback/data/repository/feedback_repo_impl.dart';
import 'package:camera_app/features/feedback/domain_layer/repository/feedback_repository.dart';
import 'package:camera_app/features/feedback/domain_layer/usecase/send_feedback_usecase.dart';
import 'package:camera_app/features/feedback/presentation/bloc/bloc/feedback_bloc.dart';
import 'package:camera_app/features/theme/data/data_source/theme_local_datasource.dart';
import 'package:camera_app/features/theme/data/repository/repo_implemetation.dart';
import 'package:camera_app/features/theme/domain/repository/app_theme_entity.dart';
import 'package:camera_app/features/theme/domain/usecase/load_font_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/load_theme_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/save_font_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/save_theme_usecase.dart';
import 'package:camera_app/features/theme/presenation/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Features - Text To Speech (New)
import 'features/text_to_speech/domain/repositories/tts_repository.dart';
import 'features/text_to_speech/data/repositories/tts_repository_impl.dart';
import 'features/text_to_speech/data/datasources/tts_remote_datasource.dart';
import 'features/text_to_speech/domain/usecases/speak_text_usecase.dart';
import 'features/text_to_speech/presentation/bloc/tts_bloc.dart';


// Create a GetIt instance
final sl = GetIt.instance; // sl stands for Service Locator

Future<void> initServiceLocator() async {
  // --- Features - Sign Translation ---

  // BLoC
  // RegisterFactory: creates a new instance each time it's requested.
  // Good for BLoCs/Cubes as their lifecycle might be tied to specific widgets/pages.
  sl.registerFactory(
    () => SignTranslationBloc(
      translateSignUseCase: sl(), // GetIt will resolve TranslateSignUseCase
    ),
  );

  // Use Cases
  // RegisterLazySingleton: creates a single instance when it's first requested.
  sl.registerLazySingleton(() => TranslateSignUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<SignTranslationRepository>(
    () => SignTranslationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<SignTranslationRemoteDataSource>(
    () => SignTranslationRemoteDataSourceImpl(
      client: sl(), // GetIt will resolve http.Client
    ),
  );

  // --- Core ---
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()), // If NetworkInfoImpl needs Connectivity
  );
  // If using internet_connection_checker:
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
  // --- External ---
  sl.registerLazySingleton(() => http.Client());
  // If using connectivity_plus:
  // sl.registerLazySingleton(() => Connectivity());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<FeedbackRepository>(() => FeedbackRepositoryImpl(
        remoteDataSource: sl<FeedbackRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ));

  sl.registerLazySingleton<SendFeedbackUseCase>(
    () => SendFeedbackUseCase(sl<FeedbackRepository>()),
  );
  sl.registerFactory<FeedbackBloc>(
    () => FeedbackBloc(sendFeedback: sl<SendFeedbackUseCase>()),
  );

  sl.registerLazySingleton(() => ThemeLocalDataSource(sl()));
  sl.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoadTheme(sl()));
  sl.registerLazySingleton(() => SaveTheme(sl()));
  sl.registerLazySingleton(() => SaveFontSize(sl()));
  sl.registerLazySingleton(() => LoadFontSize(sl()));

  final themeProvider = ThemeProvider(
    loadThemeUseCase: sl(),
    saveThemeUseCase: sl(),
    loadFontSizeUseCase: sl(),
    saveFontSizeUseCase: sl(),
  );

  await themeProvider.init(); // Load saved theme before app starts
  sl.registerSingleton<ThemeProvider>(themeProvider);

  // --- Features - Text To Speech --- (New)
  // BLoC
  sl.registerFactory(
    () => TtsBloc(speakTextUseCase: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SpeakTextUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<TtsRepository>(
    () => TtsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<TtsRemoteDataSource>(
    () => TtsRemoteDataSourceImpl(client: sl()),
  );
sl.registerFactory(() => AudioPlayer());

}
