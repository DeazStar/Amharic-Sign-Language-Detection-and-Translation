import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera_app/features/reference/domain/video_model.dart';

class FirebaseVideoRepository implements VideoRepository {
  final FirebaseFirestore _db;
  FirebaseVideoRepository(this._db);

  static const _mainCol = 'videos';
  static const _variantsCol = 'more videos';

  Video _fromDoc(DocumentSnapshot d) => Video(
    id: d.id,
    title: d['title'],
    url: d['url'],
    thumb: d['thumb'], // make sure you store this field!
  );

  @override
  Future<List<Video>> getMainVideos() async {
    final snap = await _db.collection(_mainCol).get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<Video>> watchVariantVideos(String title) {
    return _db
        .collection(_variantsCol)
        .where('title', isEqualTo: title)
        .snapshots()
        .map((q) => q.docs.map(_fromDoc).toList());
  }
}
