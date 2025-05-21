import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  final String filePath;
  final bool isVideo;

  const PreviewPage({
    super.key,
    required this.filePath,
    required this.isVideo,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final TextEditingController _textController = TextEditingController();
  String _displayText = "Initializing...";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideo ? "Video Preview" : "Image Analysis"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Preview Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: _buildMediaPreview(),
              ),
            ),
            const SizedBox(height: 20),
            // Analysis Output Area
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: _isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 15),
                          Text("Analyzing image...", style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : SingleChildScrollView(
                        child: TextField(
                          controller: _textController,
                          readOnly: true,
                          maxLines: null,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: "Model output will appear here...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Builds the preview widget
  Widget _buildMediaPreview() {
    if (widget.isVideo) {
      // Placeholder for video
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, size: 100, color: Colors.grey),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Video analysis not implemented.\nSaved at: ${widget.filePath}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      );
    } else {
      // Display the image
      File imageFile = File(widget.filePath);
      if (imageFile.existsSync()) {
        return FutureBuilder(
            future: imageFile.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error reading image file'));
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Error displaying image'));
                    },
                  );
                } else {
                  return const Center(child: Text('Image file is empty or invalid'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            });
      } else {
        return const Center(child: Text('Image file not found'));
      }
    }
  }
}