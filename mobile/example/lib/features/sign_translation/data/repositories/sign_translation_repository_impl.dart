// lib/features/sign_translation/data/repositories/sign_translation_repository_impl.dart

import 'dart:io'; // For File and SocketException
import 'package:dartz/dartz.dart'; // For Either type

// Core dependencies
import '../../../../core/error/exceptions.dart'; // ServerException, CacheException, etc.
import '../../../../core/error/failure.dart'; // Abstract Failure class (ServerFailure, CacheFailure)
import '../../../../core/network/network_info.dart'; // Optional: To check network connectivity
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo

// Domain layer dependencies
import '../../domain/entities/translation_result.dart'; // The core domain entity
import '../../domain/repositories/sign_translation_repository.dart'; // The repository contract

// Data layer dependencies
import '../datasources/sign_translation_remote_datasource.dart'; // Remote data source contract
// import '../datasources/sign_translation_local_datasource.dart'; // Optional: Local data source contract

/// Concrete implementation of the [SignTranslationRepository] interface.
///
/// This class orchestrates data fetching between different data sources
/// (remote and potentially local cache in the future). It handles errors,
/// checks network connectivity, and maps data models to domain entities.
class SignTranslationRepositoryImpl implements SignTranslationRepository {
  final SignTranslationRemoteDataSource remoteDataSource;
  // final SignTranslationLocalDataSource localDataSource; // Optional: For caching
  final NetworkInfo networkInfo; // Optional: For checking connectivity

  SignTranslationRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource, // Uncomment if using local cache
    required this.networkInfo, // Uncomment if using NetworkInfo
  });

  @override
  Future<Either<Failure, TranslationResult>> translateFromFile({
    required File file,
    required InputType inputType,
  }) async {
    // 1. (Optional) Check network connectivity before making the API call
    if ( await networkInfo.isConnected) {
      // 2. Try fetching data from the remote source
      try {
        final remoteResultModel = await remoteDataSource.translateFromFile(
          file: file,
          inputType: inputType,
        );
        // 3. (Optional) Cache the result locally if needed
        // await localDataSource.cacheTranslationResult(remoteResultModel);

        // 4. Convert the data Model to the domain Entity and return success (Right side of Either)
        // Since TranslationResultModel extends TranslationResult, we can return it directly.
        // If using composition, you'd call a .toEntity() method here.
        return Right(remoteResultModel);
      } on ServerException catch (e) {
        // 5a. Handle specific API errors and return a ServerFailure (Left side of Either)
        return Left(ServerFailure(message: 'Failed to connect to the server'));
      } on SocketException {
        // Handle cases where the network check passed but the connection dropped during the request
         return const Left(ServerFailure(message: 'Failed to connect to the server.'));
      } catch (e) {
         // Handle unexpected errors during the process
         print('Unexpected error in repository: $e'); // Log the error
         return Left(ServerFailure(message: 'An unexpected error occurred please try again later.'));
      }
    } else {
      // 5b. Handle no network connection case
      // (Optional: Try fetching from cache if implemented)
      // try {
      //   final localResult = await localDataSource.getLastTranslationResult();
      //   return Right(localResult);
      // } on CacheException {
      //   return Left(CacheFailure());
      // }
      return const Left(ServerFailure(message: 'No Internet Connection')); // Or a specific NetworkFailure
    }
  }
}


