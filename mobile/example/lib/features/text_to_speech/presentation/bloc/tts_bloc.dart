// lib/features/text_to_speech/presentation/bloc/tts_bloc.dart
import 'dart:async';
// import 'dart:io'; // No longer needed for File operations
import 'dart:typed_data'; // Still needed for TtsAudioReady state
import 'package:bloc/bloc.dart';
// import 'package:audioplayers/audioplayers.dart'; // Removed AudioPlayer from BLoC
import 'package:flutter/material.dart'; // For debugPrint
// import 'package:path_provider/path_provider.dart'; // No longer needed for temporary directory
import '../../domain/usecases/speak_text_usecase.dart';
import './tts_event.dart';
import './tts_state.dart';

class TtsBloc extends Bloc<TtsEvent, TtsState> {
  final SpeakTextUseCase speakTextUseCase;
  // final AudioPlayer audioPlayer; // Removed AudioPlayer dependency
  // StreamSubscription? _playerStateSubscription; // Removed
  // String? _currentTempFilePath; // Removed

  TtsBloc({required this.speakTextUseCase}) // Removed audioPlayer from constructor
      : super(TtsInitial()) {
    on<SynthesizeTextEvent>(_onSynthesizeTextEvent);
    on<ResetTtsStateEvent>(_onResetTtsStateEvent);

    // Removed event handlers for internal player states
    // Removed _playerStateSubscription and its listener
  }

  // Future<void> _deleteTempFile() async { ... } // Removed

  Future<void> _onSynthesizeTextEvent(
    SynthesizeTextEvent event,
    Emitter<TtsState> emit,
  ) async {
    debugPrint("TTS_BLOC: Received SynthesizeTextEvent for text: ${event.params.text}");
    // await _deleteTempFile(); // Removed
    // await audioPlayer.stop(); // Removed
    debugPrint("TTS_BLOC: Emitting TtsLoading.");
    emit(TtsLoading());

    final failureOrAudioResult = await speakTextUseCase(event.params);

    if (emit.isDone) {
      debugPrint("TTS_BLOC: Emitter is done after use case call. Aborting.");
      return;
    }
    debugPrint(failureOrAudioResult.isLeft()
        ? "TTS_BLOC: Use case returned failure."
        : "TTS_BLOC: Use case returned success with audio bytes.");
    failureOrAudioResult.fold(
      (failure) {
        debugPrint("TTS_BLOC: TTS synthesis failed: ${failure.message}");
        if (!emit.isDone) emit(TtsFailure(message: failure.message ?? "TTS synthesis failed"));
      },
      (audioResult) { // audioResult is TtsAudioResult containing Uint8List audioBytes
        debugPrint("TTS_BLOC: TTS synthesis successful. Received ${audioResult.audioBytes.lengthInBytes} bytes.");
        if (emit.isDone) return;
        
        if (audioResult.audioBytes.isEmpty) {
          debugPrint("TTS_BLOC: Audio bytes are empty. Emitting failure.");
          if (!emit.isDone) emit(TtsFailure(message: "Received empty audio data from TTS service."));
          return;
        }
        
        // Emit TtsAudioReady with the fetched bytes. UI will handle playback.
        emit(TtsAudioReady(audioBytes: audioResult.audioBytes));
        debugPrint("TTS_BLOC: Emitted TtsAudioReady with audio data.");

        // Removed all logic related to saving to file and playing with audioPlayer here.
      },
    );
  }

  // Future<void> _onStopTtsAudioEvent(...) // Removed as BLoC doesn't control playback

  Future<void> _onResetTtsStateEvent(
    ResetTtsStateEvent event,
    Emitter<TtsState> emit,
  ) async {
    debugPrint("TTS_BLOC: Received ResetTtsStateEvent.");
    // await audioPlayer.stop(); // Removed
    if (!emit.isDone) emit(TtsInitial()); 
  }

  @override
  Future<void> close() {
    debugPrint("TTS_BLOC: Closing BLoC.");
    // _playerStateSubscription?.cancel(); // Removed
    // _deleteTempFile(); // Removed
    // audioPlayer.dispose(); // Removed
    return super.close();
  }
}
