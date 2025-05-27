import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_app/features/reference/data/video_repo.dart';
import 'package:camera_app/features/reference/domain/video_model.dart';
import 'package:video_player/video_player.dart';

final videoRepoProvider = Provider<VideoRepository>(
  (ref) => FirebaseVideoRepository(FirebaseFirestore.instance),
);

final mainVideosFutureProvider = FutureProvider<List<Video>>(
  (ref) => ref.watch(videoRepoProvider).getMainVideos(),
);

final variantVideosProvider = StreamProvider.family<List<Video>, String>(
  (ref, title) => ref.watch(videoRepoProvider).watchVariantVideos(title),
);
