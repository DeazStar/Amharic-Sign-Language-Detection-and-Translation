// lib/features/sign_language_detection/presentation/pages/preview_page.dart

import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart'; // For UI-controlled playback
import 'package:path_provider/path_provider.dart'; // For temporary file

// Import BLoC, Event, State from the sign_translation feature
import '../../../sign_translation/presentation/bloc/sign_translation_bloc.dart';
import '../../../sign_translation/presentation/bloc/sign_translation_event.dart';
import '../../../sign_translation/presentation/bloc/sign_translation_state.dart';

// Import BLoC, Event, State from the text_to_speech feature
import '../../../text_to_speech/presentation/bloc/tts_bloc.dart';
import '../../../text_to_speech/presentation/bloc/tts_event.dart';
import '../../../text_to_speech/presentation/bloc/tts_state.dart';
import '../../../text_to_speech/domain/entities/tts_request_params.dart';


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
  
  // UI-managed AudioPlayer
  final AudioPlayer _uiAudioPlayer = AudioPlayer();
  bool _isUiAudioPlaying = false;
  String? _currentUiTempAudioFilePath; // To play from file
  Uint8List? _latestFetchedAudioBytes; // Store the latest fetched bytes

  // Store BLoC instances
  late TtsBloc _ttsBlocInstance;
  // SignTranslationBloc instance can also be stored if needed in dispose, but not currently used there.

  @override
  void initState() {
    super.initState();

    // Get BLoC instances in initState
    _ttsBlocInstance = context.read<TtsBloc>();
    // _signTranslationBlocInstance = context.read<SignTranslationBloc>(); // If needed

    _uiAudioPlayer.onPlayerStateChanged.listen((playerState) {
      if (mounted) {
        setState(() {
          _isUiAudioPlaying = playerState == PlayerState.playing;
        });
        if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
          _deleteUiTempAudioFile(); // Clean up after playing or stopping
        }
      }
    });
     _uiAudioPlayer.onLog.listen((msg) { 
        debugPrint("UI_AudioPlayer Log: $msg");
    });


    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play(); 
            _videoController?.setLooping(true);
            _videoController?.addListener(_videoPlayerListener);
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
    // _initiateTranslation(); // Call this via button press now
  }

  void _videoPlayerListener() {
    if (mounted && _videoController != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoPlayerListener);
    _videoController?.dispose();
    _uiAudioPlayer.release(); 
    _uiAudioPlayer.dispose();
    _deleteUiTempAudioFile(); 
    // Use the stored BLoC instance in dispose
    _ttsBlocInstance.add(ResetTtsStateEvent());
    super.dispose();
  }

  Future<void> _deleteUiTempAudioFile() async {
    if (_currentUiTempAudioFilePath != null) {
      try {
        final file = File(_currentUiTempAudioFilePath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint("UI: Temporary audio file deleted: $_currentUiTempAudioFilePath");
        }
      } catch (e) {
        debugPrint("UI: Error deleting temporary audio file: $e");
      }
      _currentUiTempAudioFilePath = null;
    }
  }

  void _initiateTranslation() {
    final File fileToTranslate = File(widget.filePath);
    final InputType inputType = widget.isVideo ? InputType.video : InputType.photo;
    
    _uiAudioPlayer.stop();
    setState(() {
      _latestFetchedAudioBytes = null;
      _isUiAudioPlaying = false;
    });
    _deleteUiTempAudioFile();
    // Use stored instance or context.read if it's safe (e.g., not in dispose)
    _ttsBlocInstance.add(ResetTtsStateEvent()); 
    
    context.read<SignTranslationBloc>().add(
          TranslateSignFileEvent(file: fileToTranslate, inputType: inputType),
        );
  }

  Future<void> _playAudioFromBytes(Uint8List audioBytes) async {
    if (audioBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio data to play.'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      await _deleteUiTempAudioFile(); 
      final tempDir = await getTemporaryDirectory();
      _currentUiTempAudioFilePath = '${tempDir.path}/ui_tts_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File(_currentUiTempAudioFilePath!);
      await file.writeAsBytes(audioBytes, flush: true);

      if (await file.exists() && (await file.length()) > 0) {
        await _uiAudioPlayer.play(DeviceFileSource(_currentUiTempAudioFilePath!));
      } else {
        throw Exception("Failed to create valid temporary audio file for UI playback.");
      }
    } catch (e) {
      debugPrint("UI: Error playing audio from bytes: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('UI: Error playing audio: $e'), backgroundColor: Colors.red),
        );
      }
      await _deleteUiTempAudioFile();
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
            GestureDetector(
              onTap: () {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
                if (mounted) setState(() {});
              },
              child: Container(color: Colors.transparent),
            ),
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
    // Determine if the current theme is dark mode for AppBar styling
    final Brightness currentBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDarkMode = currentBrightness == Brightness.dark;
    
    // Define AppBar colors based on the theme
    final Color appBarBackgroundColor = isDarkMode ? Colors.teal.shade700 : Colors.teal;
    final Color appBarTitleColor = Colors.white; 

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideo ? 'Video Preview & Translate' : 'Image Preview & Translate'),
        backgroundColor: appBarBackgroundColor, 
        titleTextStyle: TextStyle( 
          color: appBarTitleColor,
          fontSize: 20, 
          fontWeight: FontWeight.w500, 
        ),
        iconTheme: IconThemeData(color: appBarTitleColor), 
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
              child: BlocListener<TtsBloc, TtsState>( 
                listener: (context, ttsState) {
                  if (ttsState is TtsAudioReady) {
                    setState(() {
                      _latestFetchedAudioBytes = ttsState.audioBytes;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio ready to play! Tap "Play Audio".'), backgroundColor: Colors.lightBlue),
                    );
                  } else if (ttsState is TtsFailure) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('TTS Synthesis Failed: ${ttsState.message}'), backgroundColor: Colors.deepOrange),
                    );
                  }
                },
                child: BlocConsumer<SignTranslationBloc, SignTranslationState>(
                  listener: (context, signState) {
                    if (signState is SignTranslationFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Translation Failed: ${signState.message}'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else if (signState is SignTranslationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Translation Successful!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, signState) {
                    if (signState is SignTranslationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (signState is SignTranslationSuccess) {
                      final String translatedText = signState.translationResult.translatedText;
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
                                color: Theme.of(context).colorScheme.surfaceVariant, 
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)
                              ),
                              child: Text(
                                translatedText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSerifEthiopic',
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<TtsBloc, TtsState>(
                              // Use the stored instance for BlocBuilder if context is an issue,
                              // but usually context.watch/read is fine in build methods.
                              // For consistency, one might use _ttsBlocInstance here too if preferred,
                              // but BlocBuilder is designed to work with context.watch implicitly.
                              bloc: _ttsBlocInstance, // Explicitly provide the BLoC instance
                              builder: (context, ttsState) {
                                IconData ttsIcon;
                                String ttsButtonText;
                                VoidCallback? ttsOnPressed;
                                Color buttonColor;

                                if (ttsState is TtsLoading) {
                                  ttsIcon = Icons.hourglass_empty;
                                  ttsButtonText = 'Converting...';
                                  ttsOnPressed = null; 
                                  buttonColor = Colors.grey;
                                } else if (_isUiAudioPlaying) {
                                  ttsIcon = Icons.stop_circle_outlined;
                                  ttsButtonText = 'Stop Audio';
                                  ttsOnPressed = () {
                                    _uiAudioPlayer.stop();
                                  };
                                  buttonColor = Colors.redAccent;
                                } else if (_latestFetchedAudioBytes != null && ttsState is! TtsLoading) { 
                                  ttsIcon = Icons.play_circle_outline;
                                  ttsButtonText = 'Play Audio';
                                  ttsOnPressed = () {
                                    _playAudioFromBytes(_latestFetchedAudioBytes!);
                                  };
                                  buttonColor = Colors.green; 
                                } else { 
                                  ttsIcon = Icons.volume_up;
                                  ttsButtonText = 'Convert to Speech';
                                  if (ttsState is TtsFailure) {
                                    ttsButtonText = 'Retry Conversion';
                                    buttonColor = Colors.orange;
                                  } else {
                                    buttonColor = Colors.teal;
                                  }
                                  ttsOnPressed = () {
                                    if (translatedText.isNotEmpty) {
                                      final params = TtsRequestParams(
                                        text: translatedText,
                                        languageCode: "am-ET", 
                                        voiceName: "am-ET-Standard-A", 
                                      );
                                      _ttsBlocInstance.add(SynthesizeTextEvent(params: params));
                                    }
                                  };
                                }

                                return ElevatedButton.icon(
                                  icon: Icon(ttsIcon),
                                  label: Text(ttsButtonText),
                                  onPressed: translatedText.isEmpty ? null : ttsOnPressed,
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Translate Another / Clear'),
                              onPressed: () {
                                _uiAudioPlayer.stop(); 
                                setState(() { _latestFetchedAudioBytes = null; _isUiAudioPlaying = false; }); 
                                _deleteUiTempAudioFile();
                                _ttsBlocInstance.add(ResetTtsStateEvent()); // Use stored instance
                                if (widget.isVideo && _videoController != null && _videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                }
                                context.read<SignTranslationBloc>().add(ResetSignTranslationEvent());
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
          ),
        ],
      ),
    );
  }
}
