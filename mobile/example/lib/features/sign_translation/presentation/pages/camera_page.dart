// lib/features/sign_language_detection/presentation/pages/camera_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:path_provider/path_provider.dart';

// Import the PreviewPage from its new location
// Make sure the project name 'camera_app' matches your actual project name
// If your project root is 'camera_app', then the import should be:
// import 'package:camera_app/featuress/sign_language_detection/presentation/pages/preview_page.dart';
// For a generic structure assuming 'camera_app' is the project name in pubspec.yaml:
import 'preview_page.dart'; // Adjusted relative path

// Keep this commented if not used or if file_utils.dart is not part of the project structure
// import '../../../../utils/file_utils.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  // Helper function to navigate to the PreviewPage
  void _navigateToPreview(BuildContext context, String filePath, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(
          filePath: filePath,
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Sign'),
        
      ),
      body: Container(
        color: Colors.white,
        child: CameraAwesomeBuilder.awesome(
          onMediaCaptureEvent: (event) {
            switch ((event.status, event.isPicture, event.isVideo)) {
              case (MediaCaptureStatus.capturing, true, false):
                debugPrint('Capturing picture...');
              case (MediaCaptureStatus.success, true, false):
                event.captureRequest.when(
                  single: (single) {
                    if (single.file != null) {
                      debugPrint('Picture saved: ${single.file!.path}');
                      _navigateToPreview(context, single.file!.path, false);
                    } else {
                      debugPrint('Picture capture success but file is null');
                    }
                  },
                  multiple: (multiple) {
                    multiple.fileBySensor.forEach((key, value) {
                      debugPrint('multiple image taken: $key ${value?.path}');
                      if (value != null) {
                        _navigateToPreview(context, value.path, false);
                        // Optionally stop after the first navigation if that's desired
                        // return;
                      }
                    });
                  },
                );
              case (MediaCaptureStatus.failure, true, false):
                debugPrint('Failed to capture picture: ${event.exception}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to capture picture: ${event.exception}')),
                );
              case (MediaCaptureStatus.capturing, false, true):
                debugPrint('Capturing video...');
              case (MediaCaptureStatus.success, false, true):
                event.captureRequest.when(
                  single: (single) {
                    if (single.file != null) {
                      debugPrint('Video saved: ${single.file!.path}');
                      _navigateToPreview(context, single.file!.path, true);
                    } else {
                      debugPrint('Video capture success but file is null');
                    }
                  },
                  multiple: (multiple) {
                    multiple.fileBySensor.forEach((key, value) {
                      debugPrint('multiple video taken: $key ${value?.path}');
                      if (value != null) {
                        _navigateToPreview(context, value.path, true);
                        // return;
                      }
                    });
                  },
                );
              case (MediaCaptureStatus.failure, false, true):
                debugPrint('Failed to capture video: ${event.exception}');
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to capture video: ${event.exception}')),
                );
              default:
                debugPrint('Unknown media capture event: $event');
            }
          },
          saveConfig: SaveConfig.photoAndVideo(
            initialCaptureMode: CaptureMode.photo,
            photoPathBuilder: (sensors) async {
              final Directory extDir = await getTemporaryDirectory();
              final testDir = await Directory(
                '${extDir.path}/camerawesome_media', // Changed folder name slightly
              ).create(recursive: true);
              if (sensors.length == 1) {
                final String filePath =
                    '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                return SingleCaptureRequest(filePath, sensors.first);
              }
              return MultipleCaptureRequest(
                {
                  for (final sensor in sensors)
                    sensor:
                        '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                },
              );
            },
            videoPathBuilder: (sensors) async {
              final Directory extDir = await getTemporaryDirectory();
              final testDir = await Directory(
                '${extDir.path}/camerawesome_media',
              ).create(recursive: true);
              final String filePath =
                  '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
              // Assuming single sensor for video for simplicity with current camerawesome setup
              return SingleCaptureRequest(filePath, sensors.first);
            },
            videoOptions: VideoOptions(
              enableAudio: true,
              ios: CupertinoVideoOptions(
                fps: 10, // Consider if 10fps is sufficient
              ),
              android: AndroidVideoOptions(
                bitrate: 6000000, // 6 Mbps
                fallbackStrategy: QualityFallbackStrategy.lower,
              ),
            ),
            exifPreferences: ExifPreferences(saveGPSLocation: true), // Consider privacy implications
          ),
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.back),
            flashMode: FlashMode.auto,
            aspectRatio: CameraAspectRatios.ratio_4_3,
            zoom: 0.0,
          ),
          enablePhysicalButton: true,
          previewAlignment: Alignment.center,
          previewFit: CameraPreviewFit.contain,
          availableFilters: awesomePresetFiltersList,
          // onMediaTap can be used for quick preview or actions before full navigation
          onMediaTap: (mediaCapture) {
            debugPrint('onMediaTap triggered for ${mediaCapture.status}');
            // Example: Maybe show a quick overlay, or if you implement a gallery view within CameraAwesome
          },
        ),
      ),
    );
  }
}
