// reference_page.dart – v2 (lazy‑loaded video thumbnails)
// Only a thumbnail (first frame) is shown at first. The full video
// stream is fetched only when the user taps the play icon.
// ─────────────────────────────────────────────────────────────────────────────

// DOMAIN LAYER
class Video {
  final String id;
  final String title;
  final String url; // full video URL (Google Drive)
  final String thumb; // URL to first‑frame thumbnail stored in Firestore

  const Video({
    required this.id,
    required this.title,
    required this.url,
    required this.thumb,
  });
}

abstract class VideoRepository {
  Future<List<Video>> getMainVideos();
  Stream<List<Video>> watchVariantVideos(String title);
}
