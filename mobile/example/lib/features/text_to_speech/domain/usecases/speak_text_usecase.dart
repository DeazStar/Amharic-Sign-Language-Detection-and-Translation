import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart'; // Assuming UseCase base class exists
import '../entities/tts_request_params.dart';
import '../entities/tts_audio_result.dart';
import '../repositories/tts_repository.dart';

class SpeakTextUseCase
    implements UseCase<TtsAudioResult, TtsRequestParams> {
  final TtsRepository repository;

  SpeakTextUseCase(this.repository);

  @override
  Future<Either<Failure, TtsAudioResult>> call(
      TtsRequestParams params) async {
    return await repository.speakText(params: params);
  }
}