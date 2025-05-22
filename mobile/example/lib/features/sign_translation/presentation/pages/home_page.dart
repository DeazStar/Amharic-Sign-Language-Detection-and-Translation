// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
// We will create these components next
import '../../../../features/sign_translation/presentation/widgets/camera_component.dart';
import '../../../../features/sign_translation/presentation/widgets/preview_component.dart';

// Data structure to hold captured media info
class CapturedMedia {
  final String filePath;
  final bool isVideo;

  CapturedMedia({required this.filePath, required this.isVideo});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CapturedMedia? _capturedMedia;

  // Callback for when media is captured by CameraComponent
  void _onMediaCaptured(String filePath, bool isVideo) {
    setState(() {
      _capturedMedia = CapturedMedia(filePath: filePath, isVideo: isVideo);
    });
  }

  // Callback for when user wants to go back from PreviewComponent to CameraComponent
  void _clearPreview() {
    setState(() {
      _capturedMedia = null;
    });
    // Optionally, also reset the SignTranslationBloc state if needed
    // context.read<SignTranslationBloc>().add(ResetSignTranslationEvent());
  }

  @override
  Widget build(BuildContext context) {
    // The HomePage itself doesn't need its own Scaffold if it's part of MainNavigationPage's body
    if (_capturedMedia == null) {
      return CameraComponent(onMediaCaptured: _onMediaCaptured);
    } else {
      return PreviewComponent(
        filePath: _capturedMedia!.filePath,
        isVideo: _capturedMedia!.isVideo,
        onClosePreview: _clearPreview, // Pass the callback to allow going back
      );
    }
  }
}
