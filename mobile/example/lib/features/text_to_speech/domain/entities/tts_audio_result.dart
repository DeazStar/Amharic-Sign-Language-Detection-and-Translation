// lib/features/text_to_speech/domain/entities/tts_audio_result.dart
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class TtsAudioResult extends Equatable {
  final Uint8List audioBytes;

  const TtsAudioResult({required this.audioBytes});

  @override
  List<Object?> get props => [audioBytes];
}
