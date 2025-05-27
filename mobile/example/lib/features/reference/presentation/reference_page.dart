import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_app/features/reference/presentation/carosuel.dart';
import 'package:camera_app/features/reference/presentation/video_card.dart';
import 'package:camera_app/features/reference/presentation/video_provider.dart';
import 'package:camera_app/features/reference/presentation/video_title.dart';

class ReferencePage extends ConsumerWidget {
  const ReferencePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(mainVideosFutureProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reference')),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (videos) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (_, i) => VideoTile(video: videos[i]),
        ),
      ),
    );
  }
}
