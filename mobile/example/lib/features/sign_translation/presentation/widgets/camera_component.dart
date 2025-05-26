// lib/features/sign_language_detection/presentation/components/camera_component.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:path_provider/path_provider.dart';

class CameraComponent extends StatelessWidget {
  final Function(String filePath, bool isVideo) onMediaCaptured;

  const CameraComponent({super.key, required this.onMediaCaptured});

  @override
  Widget build(BuildContext context) {
    // No Scaffold here, this is now a component.
    // The AppBar is removed as it would typically be part of the parent Scaffold (MainNavigationPage).
    // If you need a title specific to this view, the parent (HomePage or MainNavigationPage) should handle it.
    return Container( // Or any other appropriate root widget for the component
      color: Colors.white, // Or transparent if the parent handles background
      child: CameraAwesomeBuilder.awesome(
        // Using context from the build method of CameraComponent
        onMediaCaptureEvent: (event) {
          switch ((event.status, event.isPicture, event.isVideo)) {
            case (MediaCaptureStatus.capturing, _, _):
              debugPrint('Capturing media...');
              // Optionally show a subtle loading indicator via a state management solution
              // accessible here if the capture takes time.
              break;
            case (MediaCaptureStatus.success, true, false): // Picture success
              event.captureRequest.when(
                single: (single) {
                  if (single.file != null) {
                    debugPrint('Picture saved: ${single.file!.path}');
                    onMediaCaptured(single.file!.path, false); // Notify parent
                  } else {
                    debugPrint('Picture capture success but file is null');
                  }
                },
                multiple: (multiple) { // Handle if multiple pictures can be taken
                  final firstFile = multiple.fileBySensor.values.firstWhere((f) => f != null, orElse: () => null);
                  if (firstFile != null) {
                     debugPrint('Multiple pictures saved, using first: ${firstFile.path}');
                    onMediaCaptured(firstFile.path, false); // Notify parent with the first valid file
                  } else {
                     debugPrint('Multiple picture capture success but all files are null');
                  }
                },
              );
              break;
            case (MediaCaptureStatus.success, false, true): // Video success
              event.captureRequest.when(
                single: (single) {
                  if (single.file != null) {
                    debugPrint('Video saved: ${single.file!.path}');
                    onMediaCaptured(single.file!.path, true); // Notify parent
                  } else {
                    debugPrint('Video capture success but file is null');
                  }
                },
                multiple: (multiple) { // Handle if multiple videos can be taken
                   final firstFile = multiple.fileBySensor.values.firstWhere((f) => f != null, orElse: () => null);
                  if (firstFile != null) {
                     debugPrint('Multiple videos saved, using first: ${firstFile.path}');
                    onMediaCaptured(firstFile.path, true); // Notify parent with the first valid file
                  } else {
                     debugPrint('Multiple video capture success but all files are null');
                  }
                },
              );
              break;
            case (MediaCaptureStatus.failure, _, _):
              debugPrint('Failed to capture media: ${event.exception}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to capture media: ${event.exception}')),
              );
              break;
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
            return SingleCaptureRequest(filePath, sensors.first); // Assuming single sensor for video
          },
          videoOptions: VideoOptions(
            enableAudio: true,
            ios: CupertinoVideoOptions(fps: 10),
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
        // onMediaTap might be less relevant if navigating immediately on capture
        // onMediaTap: (mediaCapture) {
        //   debugPrint('onMediaTap triggered for ${mediaCapture.status}');
        // },
      ),
    );
  }
}
