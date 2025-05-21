// lib/features/sign_language_detection/presentation/pages/preview_page.dart

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

class PreviewPage extends StatefulWidget {
  final String filePath;
  final bool isVideo;

  const PreviewPage({
    super.key,
    required this.filePath,
    required this.isVideo,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  VideoPlayerController? _videoController; // Uncomment for video_player
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instance of AudioPlayer
  bool _isAudioPlaying = false; // To track audio playback state for UI updates

  @override
  void initState() {
    super.initState();
    // _audioPlayer.onPlayerStateChanged.listen((PlayerState s) { // For older versions
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = s == PlayerState.playing;
        });
      }
    });
    if (widget.isVideo) { // Uncomment for video_player
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
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
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Uncomment for video_player
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
      // --- Video Player Implementation (using video_player package) ---
      if (_videoController != null && _videoController!.value.isInitialized) { // Uncomment for video_player
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else if (_videoController != null && _videoController!.value.hasError) {
        return const Center(
          child: Text('Error loading video.', style: TextStyle(color: Colors.red)),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
      // --- Placeholder for Video ---
      // return Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       const Icon(Icons.videocam, size: 100, color: Colors.grey),
      //       const SizedBox(height: 10),
      //       Text('Video Preview: ${widget.filePath.split('/').last}'),
      //       const SizedBox(height: 10),
      //       const Text('(Video player implementation needed)', style: TextStyle(fontSize: 12, color: Colors.grey)),
      //     ],
      //   ),
      // );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideo ? 'Video Preview & Translate' : 'Image Preview & Translate'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black87,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: _buildMediaPreview(),
            ),
          ),
          Expanded(
            flex: 2,
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
                    return SingleChildScrollView(
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
                                fontFamily: 'NotoSerifEthiopic', // Example font name
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
                          if (hasAudio) const SizedBox(height: 10), // Spacing if audio button is present
                          ElevatedButton.icon(
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Translate Another / Clear'),
                            onPressed: () {
                              _stopAudio(); // Stop audio if playing before resetting
                              context.read<SignTranslationBloc>().add(ResetSignTranslationEvent());
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.translate),
                      label: const Text('Translate Sign'),
                      onPressed: _initiateTranslation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
