// lib/features/text_to_speech/data/repositories/tts_repository_impl.dart
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart'; // Assuming NetworkInfo exists
import '../../domain/entities/tts_request_params.dart';
import '../../domain/entities/tts_audio_result.dart';
import '../../domain/repositories/tts_repository.dart';
import '../datasources/tts_remote_datasource.dart';

class TtsRepositoryImpl implements TtsRepository {
  final TtsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TtsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TtsAudioResult>> speakText(
      {required TtsRequestParams params}) async {
    if (await networkInfo.isConnected) {
      try {
        final audioBytes = await remoteDataSource.fetchTtsAudio(
          text: params.text,
          languageCode: params.languageCode,
          voiceName: params.voiceName,
        );
        return Right(TtsAudioResult(audioBytes: audioBytes));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "Server Error", statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure(message: "Unexpected error: ${e.toString()}"));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
