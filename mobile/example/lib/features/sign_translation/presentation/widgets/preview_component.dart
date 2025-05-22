// lib/features/sign_language_detection/presentation/components/preview_component.dart

import 'dart:convert'; // For base64Decode
import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

// Uncomment if you use video_player
import 'package:video_player/video_player.dart';

// Import BLoC, Event, State from the sign_translation feature
import '../../../sign_translation/presentation/bloc/sign_translation_bloc.dart';
import '../../../sign_translation/presentation/bloc/sign_translation_event.dart';
import '../../../sign_translation/presentation/bloc/sign_translation_state.dart';
// Import InputType from core utils
import '../../../../core/utils/input_type.dart';

class PreviewComponent extends StatefulWidget {
  final String filePath;
  final bool isVideo;
  final VoidCallback onClosePreview; // Callback to go back to camera

  const PreviewComponent({
    super.key,
    required this.filePath,
    required this.isVideo,
    required this.onClosePreview,
  });

  @override
  State<PreviewComponent> createState() => _PreviewComponentState();
}

class _PreviewComponentState extends State<PreviewComponent> {
  VideoPlayerController? _videoController; // Video player controller
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instance of AudioPlayer
  bool _isAudioPlaying = false; // To track audio playback state for UI updates

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = s == PlayerState.playing;
        });
      }
    });

    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {}); // Update UI once video is initialized
            _videoController?.play(); // Optionally start playing
            _videoController?.setLooping(true); // Optionally loop
          }
        }).catchError((error) {
          debugPrint("Error initializing video player: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading video: $error')),
            );
          }
        });
    }
    // Automatically initiate translation when preview is shown
    _initiateTranslation();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.stop(); // Ensure audio is stopped
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  void _initiateTranslation() {
    final File fileToTranslate = File(widget.filePath);
    final InputType inputType = widget.isVideo ? InputType.video : InputType.photo;
    context.read<SignTranslationBloc>().add(
          TranslateSignFileEvent(file: fileToTranslate, inputType: inputType),
        );
  }

  Future<void> _playAudio(String base64Audio) async {
    try {
      if (base64Audio.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio data available.'), backgroundColor: Colors.orange),
        );
        return;
      }
      Uint8List audioBytes = base64Decode(base64Audio);
      await _audioPlayer.play(BytesSource(audioBytes));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playing audio...'), backgroundColor: Colors.blueAccent),
        );
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  Widget _buildMediaPreview() {
    if (widget.isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else if (_videoController != null && _videoController!.value.hasError) {
        return const Center(
          child: Text('Error loading video.', style: TextStyle(color: Colors.red)),
        );
      } else {
        // Show a loading indicator while the video is initializing
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      // --- Image Preview ---
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text('Error loading image: $error', style: const TextStyle(color: Colors.red)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This component does not return a Scaffold. It's part of a larger view.
    return Column(
      children: [
        // "Back to Camera" button at the top of the component
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              label: const Text("Back to Camera"),
              onPressed: () {
                _stopAudio(); // Stop any playing audio
                // Reset BLoC state before going back
                context.read<SignTranslationBloc>().add(ResetSignTranslationEvent());
                widget.onClosePreview(); // Notify parent to switch view
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              )
            ),
          ),
        ),
        Expanded(
          flex: 3, // Adjust flex factor as needed for layout
          child: Container(
            color: Colors.black87, // Background for the media preview
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: _buildMediaPreview(),
          ),
        ),
        Expanded(
          flex: 2, // Adjust flex factor for translation controls/results
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<SignTranslationBloc, SignTranslationState>(
              listener: (context, state) {
                if (state is SignTranslationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Translation Failed: ${state.message}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else if (state is SignTranslationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Translation Successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SignTranslationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SignTranslationSuccess) {
                  final bool hasAudio = state.translationResult.audioBase64 != null &&
                                        state.translationResult.audioBase64!.isNotEmpty;
                  return SingleChildScrollView( // In case content overflows
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Translation Result:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[400]!)
                          ),
                          child: Text(
                            state.translationResult.translatedText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSerifEthiopic', // Using font from your provided code
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (hasAudio)
                          ElevatedButton.icon(
                            icon: Icon(_isAudioPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                            label: Text(_isAudioPlaying ? 'Stop Audio' : 'Play Audio'),
                            onPressed: () {
                              if (_isAudioPlaying) {
                                _stopAudio();
                              } else {
                                _playAudio(state.translationResult.audioBase64!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAudioPlaying ? Colors.redAccent : Colors.blueAccent,
                            ),
                          ),
                        // The "Translate Another / Clear" button is now handled by "Back to Camera"
                      ],
                    ),
                  );
                }

                // Handle initial state or failure state where user might want to retry
                if (state is SignTranslationFailure) {
                   return Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Translation'),
                      onPressed: _initiateTranslation, // Allow retry
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  );
                }
                // Default state (usually SignTranslationInitial before auto-translation or after reset)
                // Since translation is initiated in initState, this might only be briefly visible
                // or if the BLoC is reset and no new action is taken.
                return const Center(child: Text("Awaiting translation..."));
              },
            ),
          ),
        ),
      ],
    );
  }
}
