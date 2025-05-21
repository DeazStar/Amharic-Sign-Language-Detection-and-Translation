// lib/injection_container.dart  OR  lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
// You might need to add connectivity_plus to your pubspec.yaml
// import 'package:connectivity_plus/connectivity_plus.dart';

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
    // () => NetworkInfoImpl(), // Assuming NetworkInfoImpl has a default constructor or simple setup
  );

  // --- External ---
  sl.registerLazySingleton(() => http.Client());
  // If using connectivity_plus:
  // sl.registerLazySingleton(() => Connectivity());
}
