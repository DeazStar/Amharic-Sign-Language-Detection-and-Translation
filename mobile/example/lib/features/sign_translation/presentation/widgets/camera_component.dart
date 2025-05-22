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
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Camera fills the screen
          Positioned.fill(
            child: CameraAwesomeBuilder.awesome(
              onMediaCaptureEvent: (event) {
                switch ((event.status, event.isPicture, event.isVideo)) {
                  case (MediaCaptureStatus.capturing, _, _):
                    debugPrint('Capturing media...');
                    break;
                  case (MediaCaptureStatus.success, true, false):
                    event.captureRequest.when(
                      single: (single) {
                        if (single.file != null) {
                          debugPrint('Picture saved: ${single.file!.path}');
                          onMediaCaptured(single.file!.path, false);
                        }
                      },
                      multiple: (multiple) {
                        final firstFile = multiple.fileBySensor.values.firstWhere(
                          (f) => f != null,
                          orElse: () => null,
                        );
                        if (firstFile != null) {
                          debugPrint('Multiple pictures saved, using first: ${firstFile.path}');
                          onMediaCaptured(firstFile.path, false);
                        }
                      },
                    );
                    break;
                  case (MediaCaptureStatus.success, false, true):
                    event.captureRequest.when(
                      single: (single) {
                        if (single.file != null) {
                          debugPrint('Video saved: ${single.file!.path}');
                          onMediaCaptured(single.file!.path, true);
                        }
                      },
                      multiple: (multiple) {
                        final firstFile = multiple.fileBySensor.values.firstWhere(
                          (f) => f != null,
                          orElse: () => null,
                        );
                        if (firstFile != null) {
                          debugPrint('Multiple videos saved, using first: ${firstFile.path}');
                          onMediaCaptured(firstFile.path, true);
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
                  final testDir = await Directory('${extDir.path}/camerawesome_media')
                      .create(recursive: true);
                  if (sensors.length == 1) {
                    return SingleCaptureRequest(
                      '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                      sensors.first,
                    );
                  }
                  return MultipleCaptureRequest({
                    for (final sensor in sensors)
                      sensor:
                          '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                  });
                },
                videoPathBuilder: (sensors) async {
                  final Directory extDir = await getTemporaryDirectory();
                  final testDir = await Directory('${extDir.path}/camerawesome_media')
                      .create(recursive: true);
                  return SingleCaptureRequest(
                    '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4',
                    sensors.first,
                  );
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
            ),
          ),

          // Back button on top of the camera interface
          Positioned(
            top: 16,
            left: 5,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white,size: 30,),
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
