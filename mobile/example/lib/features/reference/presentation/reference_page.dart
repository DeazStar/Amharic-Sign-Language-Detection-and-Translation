import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Assuming these imports are correct for your project structure
// and that VideoTile and mainVideosFutureProvider are defined in these files.
import 'package:camera_app/features/reference/presentation/carosuel.dart'; // Though not directly used in this snippet, keeping for context
import 'package:camera_app/features/reference/presentation/video_card.dart'; // Though not directly used, keeping for context
import 'package:camera_app/features/reference/presentation/video_provider.dart';
import 'package:camera_app/features/reference/presentation/video_title.dart'; // Assuming VideoTile is here or exported

class ReferencePage extends ConsumerWidget {
  const ReferencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(mainVideosFutureProvider);

    // Determine if the current theme is dark mode
    final Brightness currentBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDarkMode = currentBrightness == Brightness.dark;

    // Define colors based on the theme
    // You can customize these colors to match your app's overall theme
    final Color appBarBackgroundColor = isDarkMode ? Colors.teal.shade700 : Colors.teal; // Example dark/light colors
    final Color appBarTextColor = isDarkMode ? Colors.white : Colors.white; // Title color
    final Color progressIndicatorColor = isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple;
    final Color errorTextColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade700;
    final Color scaffoldBackgroundColor = isDarkMode ? Colors.black : Colors.grey.shade100;


    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Signs & Resources'), // Updated title
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarTextColor, // Sets color for title and icons like back arrow
        elevation: 1.0, // Subtle elevation
      ),
      body: listAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: progressIndicatorColor)),
        error: (e, stackTrace) {
          // It's good practice to log the full error and stack trace for debugging
          debugPrint('Error fetching videos: $e');
          debugPrint('Stack trace: $stackTrace');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: errorTextColor, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load resources.',
                    style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'Please check your connection and try again.', // More user-friendly
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    textAlign: TextAlign.center,
                  ),
                  // Optionally, add a retry button here that calls ref.refresh(mainVideosFutureProvider)
                ],
              ),
            )
          );
        },
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No resources available at the moment.',
                     style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check back later.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (_, i) => VideoTile(video: videos[i]), // Assuming VideoTile handles its own theming
          );
        },
      ),
    );
  }
}
