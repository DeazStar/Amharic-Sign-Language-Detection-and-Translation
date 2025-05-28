import 'package:flutter/material.dart';
import 'package:camera_app/features/reference/domain/video_model.dart';
import 'package:camera_app/features/reference/presentation/carosuel.dart';
import 'package:camera_app/features/reference/presentation/video_card.dart';

class VideoTile extends StatelessWidget {
  final Video video;

  const VideoTile({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoPlayerCard(url: video.url, thumb: video.thumb),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  video.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.video_collection_outlined, size: 18),
                label: Text(
                  'More videos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VariantCarouselPage(title: video.title),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
