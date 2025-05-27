// lib/features/text_to_speech/presentation/bloc/tts_state.dart
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class TtsState extends Equatable {
  const TtsState();
  @override
  List<Object?> get props => [];
}

class TtsInitial extends TtsState {}

class TtsLoading extends TtsState {} // Fetching audio from Azure

/// State indicating audio bytes have been successfully fetched and are ready for the UI.
class TtsAudioReady extends TtsState { 
  final Uint8List audioBytes; 
  const TtsAudioReady({required this.audioBytes});
  @override
  List<Object?> get props => [audioBytes];
}

class TtsFailure extends TtsState {
  final String message;
  const TtsFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// Removed TtsPlaying, TtsPaused, TtsStopped states as BLoC no longer manages playback.
