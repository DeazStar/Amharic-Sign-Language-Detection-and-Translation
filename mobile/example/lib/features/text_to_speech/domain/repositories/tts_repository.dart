// lib/features/text_to_speech/domain/repositories/tts_repository.dart
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart'; // Assuming Failure class exists in core
import '../entities/tts_request_params.dart';
import '../entities/tts_audio_result.dart';

abstract class TtsRepository {
  Future<Either<Failure, TtsAudioResult>> speakText(
      {required TtsRequestParams params});
}
