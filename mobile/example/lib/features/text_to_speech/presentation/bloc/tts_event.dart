// lib/features/text_to_speech/presentation/bloc/tts_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/tts_request_params.dart';

abstract class TtsEvent extends Equatable {
  const TtsEvent();
  @override
  List<Object?> get props => [];
}

/// Event to request synthesis of text to audio bytes.
class SynthesizeTextEvent extends TtsEvent {
  final TtsRequestParams params;
  const SynthesizeTextEvent({required this.params});
  @override
  List<Object?> get props => [params];
}

/// Event to reset the TTS state back to initial.
class ResetTtsStateEvent extends TtsEvent {}

// Removed PlayerDidStartPlaying, PlayerDidPause, PlayerDidStop, PlayerDidComplete
// Removed StopTtsAudioEvent as BLoC no longer controls playback directly.

