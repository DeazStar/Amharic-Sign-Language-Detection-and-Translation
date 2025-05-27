import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_app/features/reference/domain/video_model.dart';
import 'package:camera_app/features/reference/presentation/video_card.dart';
import 'package:camera_app/features/reference/presentation/video_provider.dart';

class VariantCarouselPage extends ConsumerWidget {
  final String title;
  const VariantCarouselPage({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVariants = ref.watch(variantVideosProvider(title));
    return Scaffold(
      appBar: AppBar(title: Text('More "$title" videos')),
      body: asyncVariants.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (variants) => variants.isEmpty
            ? const Center(child: Text('No additional videos.'))
            : PageView.builder(
                itemCount: variants.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: VideoPlayerCard(
                    url: variants[i].url,
                    thumb: variants[i].thumb,
                  ),
                ),
              ),
      ),
    );
  }
}

// class _Carousel extends StatefulWidget {
//   final List<Video> variants;
//   const _Carousel({required this.variants});

//   @override
//   State<_Carousel> createState() => _CarouselState();
// }

// class _CarouselState extends State<_Carousel> {
//   late final PageController _pc;
//   @override
//   void initState() {
//     super.initState();
//     _pc = PageController();
//   }

//   @override
//   void dispose() {
//     _pc.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       controller: _pc,
//       itemCount: widget.variants.length,
//       itemBuilder: (_, i) => Padding(
//         padding: const EdgeInsets.all(16),
//         child: VideoPlayerCard(url: widget.variants[i].url, thumb:widget[i].thumb , ),
//       ),
//     );
//   }
// }
