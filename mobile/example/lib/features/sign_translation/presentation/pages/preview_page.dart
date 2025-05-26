// lib/features/sign_language_detection/presentation/pages/preview_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  VideoPlayerController? _videoController;
  FlutterTts flutterTts = FlutterTts();
  bool _isTTSSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play(); // Auto-play
            _videoController?.setLooping(true);
            _videoController?.addListener(_videoPlayerListener); // Add listener
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

  void _videoPlayerListener() {
    if (mounted && _videoController != null) {
      setState(() {
        // This will trigger a rebuild if the playing state changes,
        // ensuring the play/pause button icon is updated.
      });
    }
  }

  Future<void> _initTts() async {
    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isTTSSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isTTSSpeaking = false);
    });
    flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() => _isTTSSpeaking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS Error: $msg'), backgroundColor: Colors.redAccent),
        );
      }
    });
    flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isTTSSpeaking = false);
    });

    // Set TTS parameters
    try {
      await flutterTts.setVolume(1.0); // Set volume to maximum
      await flutterTts.setSpeechRate(0.5); // Normal speed
      await flutterTts.setPitch(1.0); // Normal pitch
    } catch (e) {
      debugPrint("Error setting TTS parameters: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoPlayerListener);
    _videoController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _initiateTranslation() {
    final File fileToTranslate = File(widget.filePath);
    final InputType inputType = widget.isVideo ? InputType.video : InputType.photo;
    context.read<SignTranslationBloc>().add(
          TranslateSignFileEvent(file: fileToTranslate, inputType: inputType),
        );
  }

  Future<void> _speakText(String text) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to speak.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      List<dynamic> languages = await flutterTts.getLanguages;
      List<dynamic> voices = await flutterTts.getVoices;
      debugPrint("Available TTS voices: $voices");
      // print("available voices:");
      debugPrint("Available TTS languages: $languages");
      String langToSet = "eng"; // Default fallback
      bool langFound = false;

      // Try to set Amharic
      for (var lang in languages) {
        if (lang is String && (lang.toLowerCase() == "am" || lang.toLowerCase().startsWith("am-"))) {
          langToSet = lang;
          langFound = true;
          break;
        }
      }

      if (langFound) {
        debugPrint("TTS Language will be set to: $langToSet (Amharic)");
      } else {
        // If Amharic not found, try to find any English variant
        langFound = false; // Reset for English check
        for (var lang in languages) {
          if (lang is String && lang.toLowerCase().startsWith("en")) {
            langToSet = lang;
            langFound = true;
            break;
          }
        }
        if (langFound) {
          debugPrint("Amharic TTS not found, fallback to: $langToSet (English)");
        } else {
          text = "TTS language not supported. Please check your TTS settings.";
           langToSet = "en"; // Fallback to default English
          debugPrint("Amharic and common English TTS not found, using engine default language.");
           if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Amharic/English TTS not found. Using default voice.'), backgroundColor: Colors.amber),
            );
           }
        }
      }
      // await flutterTts.setLanguage(langToSet);
    // await flutterTts.setLanguage("am-ET");
    } catch (e) {
      debugPrint("Error setting TTS language: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting TTS language: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
    await flutterTts.setVolume(1.0); // Set volume to maximum
    await flutterTts.setSpeechRate(0.5);
    var result = await flutterTts.speak(text);
    // await flutterTts.setLanguage("am");
  // or
    // await flutterTts.setLanguage("am-ET");
    // var result = await flutterTts.speak("ሰላም"); 
    if (result == 1 && mounted) {
      setState(() => _isTTSSpeaking = true); // Already handled by setStartHandler
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start TTS.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _stopTTSSpeaking() async {
    var result = await flutterTts.stop();
    if (result == 1 && mounted) {
      setState(() => _isTTSSpeaking = false); // Already handled by setCompletionHandler/setCancelHandler
    }
  }

  Widget _buildMediaPreview() {
    if (widget.isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            GestureDetector( // To allow tapping anywhere on video to play/pause
              onTap: () {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
                if (mounted) setState(() {}); // Update button icon
              },
              child: Container( // Transparent container to catch taps
                color: Colors.transparent, 
              ),
            ),
            // Play/Pause button
            Positioned.fill(
              child: Center(
                child: IconButton(
                  icon: Icon(
                    _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white70,
                    size: 60.0,
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );
      } else if (_videoController != null && _videoController!.value.hasError) {
        return const Center(
          child: Text('Error loading video.', style: TextStyle(color: Colors.red)),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
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
                    final String translatedText = state.translationResult.translatedText;
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
                              translatedText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'NotoSerifEthiopic',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (translatedText.isNotEmpty)
                            ElevatedButton.icon(
                              icon: Icon(_isTTSSpeaking ? Icons.volume_off : Icons.volume_up),
                              label: Text(_isTTSSpeaking ? 'Stop Speaking' : 'Speak Text'),
                              onPressed: () {
                                if (_isTTSSpeaking) {
                                  _stopTTSSpeaking();
                                } else {
                                  _speakText(translatedText);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTTSSpeaking ? Colors.redAccent : Colors.teal,
                              ),
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Translate Another / Clear'),
                            onPressed: () {
                              _stopTTSSpeaking();
                              if (widget.isVideo && _videoController != null && _videoController!.value.isPlaying) {
                                _videoController!.pause(); // Pause video before resetting
                              }
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
