import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCard extends StatefulWidget {
  final String url;
  final String thumb;
  const VideoPlayerCard({super.key, required this.url, required this.thumb});
  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  VideoPlayerController? _controller; // Nullable
  bool _isPlaying = false;
  bool _isInitializing = false;
  bool _showThumbnail = true;
  bool _isEnded = false;

  void _videoControllerListener() {
    if (!mounted || _controller == null) return;

    if (_isPlaying != _controller!.value.isPlaying) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
    if (_controller!.value.isInitialized &&
        _controller!.value.position >= _controller!.value.duration &&
        !_controller!.value.isPlaying &&
        !_isEnded) {
      setState(() {
        _isEnded = true;
        _isPlaying = false;
      });
    }
    if (_controller!.value.hasError) {
       debugPrint("VideoPlayerController Error: ${_controller!.value.errorDescription}");
       setState(() {
         _isInitializing = false;
         _showThumbnail = true;
         _isPlaying = false;
         _isEnded = true;
       });
    }
  }

  Future<void> _initAndPlay() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _showThumbnail = false;
      _isEnded = false;
      _isPlaying = false;
    });

    // Dispose previous controller if it exists
    _controller?.removeListener(_videoControllerListener);
    await _controller?.dispose();
    
    try {
      final Uri videoUri = Uri.parse(widget.url);
      _controller = VideoPlayerController.networkUrl(videoUri); // Assign new controller
      _controller!.addListener(_videoControllerListener);

      await _controller!.initialize();
      if (!mounted) {
        _controller?.dispose(); // Clean up if widget is disposed during init
        return;
      }

      await _controller!.play();
      setState(() {
        _isInitializing = false;
        _isPlaying = true; 
      });

    } catch (e) {
      debugPrint("Error initializing or playing video: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _showThumbnail = true;
          _controller = null; // Ensure controller is null on failure
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: ${e.toString()}')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) {
      if (!_isInitializing) {
          _initAndPlay();
      }
      return;
    }

    if (_isEnded) {
      _controller!.seekTo(Duration.zero).then((_) {
        _controller!.play();
        if (mounted) {
          setState(() {
            _isPlaying = true; // Will also be set by listener
            _isEnded = false;
          });
        }
      });
    } else if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    // Listener will update _isPlaying and trigger setState
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoControllerListener);
    _controller?.dispose(); // Null-safe dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller is ready if it's not null AND its value is initialized
    final bool isControllerReady = _controller != null && _controller!.value.isInitialized;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 12,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (isControllerReady && !_showThumbnail)
              VideoPlayer(_controller!) // Use null assertion here because of isControllerReady check
            else if (_showThumbnail)
              Image.network(
                widget.thumb,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black87,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                     color: Colors.black87,
                     child: const Center(child: CircularProgressIndicator(color: Colors.white))
                  );
                },
              )
            else 
              Container(color: Colors.black87),

            if (_isInitializing && !_showThumbnail)
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            if (_showThumbnail || isControllerReady || _isInitializing)
              GestureDetector(
                onTap: _isInitializing ? null : _togglePlayPause,
                child: Container(
                  color: (_showThumbnail && !isControllerReady && !_isInitializing) || _isInitializing
                      ? Colors.black38 
                      : Colors.transparent,
                  child: Center(
                    child: _isInitializing
                        ? const SizedBox.shrink() 
                        : Icon(
                            _isEnded
                                ? Icons.replay_circle_filled_outlined
                                // Check isControllerReady before accessing _controller!.value.isPlaying
                                : (isControllerReady && _controller!.value.isPlaying 
                                    ? Icons.pause_circle_filled 
                                    : Icons.play_circle_filled),
                            size: 64,
                            color: Colors.white.withOpacity(0.9),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}