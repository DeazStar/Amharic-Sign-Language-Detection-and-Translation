// lib/features/sign_translation/presentation/pages/camera_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:path_provider/path_provider.dart';

// Import the PreviewPage from its new location
// Ensure this path is correct based on your project structure.
import 'preview_page.dart';

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
    // Determine if the current theme is dark mode
    final Brightness currentBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDarkMode = currentBrightness == Brightness.dark;

    // Define colors based on the theme
    final Color appBarBackgroundColor = isDarkMode ? Colors.teal.shade700 : Colors.teal;
    final Color appBarTitleColor = isDarkMode ? Colors.white : Colors.white; // Title is white in both for better contrast on teal/black
    final Color cameraBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.white;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Sign'),
        backgroundColor: appBarBackgroundColor,
        titleTextStyle: TextStyle(
          color: appBarTitleColor,
          fontSize: 20, // Default AppBar title size
          fontWeight: FontWeight.w500, // Default AppBar title weight
        ),
        iconTheme: IconThemeData(
          color: appBarTitleColor, // For back button, etc.
        ),
      ),
      body: Container(
        color: cameraBackgroundColor, // Set background for the camera view area
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
                        // return; // Optionally stop after the first navigation
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
                '${extDir.path}/camerawesome_media',
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
              return SingleCaptureRequest(filePath, sensors.first);
            },
            videoOptions: VideoOptions(
              enableAudio: true,
              ios: CupertinoVideoOptions(
                fps: 10,
              ),
              android: AndroidVideoOptions(
                bitrate: 6000000, 
                fallbackStrategy: QualityFallbackStrategy.lower,
              ),
            ),
            exifPreferences: ExifPreferences(saveGPSLocation: true),
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
          onMediaTap: (mediaCapture) {
            debugPrint('onMediaTap triggered for ${mediaCapture.status}');
          },
        ),
      ),
    );
  }
}
