// lib/features/feedback/presentation/pages/feedback_list_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode
import 'package:intl/intl.dart'; // For date formatting

// Define a simple Feedback model (adjust based on your actual backend response)
class FeedbackItem {
  final String id; // Or int
  final String content;
  final DateTime createdAt; // Example field
  // final String userEmail; // You might want to add this back if your API provides it

  FeedbackItem({
    required this.id,
    required this.content,
    required this.createdAt,
    // this.userEmail = "Anonymous", // Default if not provided
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id']?.toString() ?? 'unknown_id_${DateTime.now().millisecondsSinceEpoch}',
      content: json['feedback_text'] ?? json['message'] ?? json['content'] ?? 'No content provided',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      // userEmail: json['user_email'] ?? 'Anonymous',
    );
  }
}

class FeedbackListPage extends StatefulWidget {
  final String accessToken;

  const FeedbackListPage({super.key, required this.accessToken});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  bool _isLoading = true;
  List<FeedbackItem> _feedbacks = [];
  String? _errorMessage;

  // TODO: Replace with your actual feedbacks endpoint
  final String _feedbacksUrl = "http://18.188.141.168:8000/feedbacks"; // Your provided URL

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint("Fetching feedbacks from: $_feedbacksUrl");
      debugPrint("Using Access Token: Bearer ${widget.accessToken.substring(0, 10)}..."); // Log part of token for verification

      final response = await http.get(
        Uri.parse(_feedbacksUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20)); // Added timeout

      debugPrint("Feedback API Response Status: ${response.statusCode}");
      // debugPrint("Feedback API Response Body: ${response.body}");


      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes); // Ensure UTF-8 decoding
        final List<dynamic> responseData = jsonDecode(responseBody);
        if (mounted) {
          setState(() {
            _feedbacks = responseData.map((data) => FeedbackItem.fromJson(data)).toList();
            _isLoading = false;
          });
        }
      } else {
         String errorMsg = "Failed to load feedbacks. Status: ${response.statusCode}";
         try {
            final decodedError = jsonDecode(response.body);
            errorMsg += " - ${decodedError['detail'] ?? response.body}";
         } catch(_){
            errorMsg += " - ${response.body}";
         }
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
            _feedbacks = []; 
            _isLoading = false;
          });
        }
      }
    } catch (e, s) {
      debugPrint("Error fetching feedbacks: $e\nStacktrace: $s");
      if (mounted) {
        setState(() {
          _errorMessage = "An error occurred: ${e.toString()}";
          _feedbacks = []; 
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness currentBrightness = MediaQuery.platformBrightnessOf(context);
    final bool isDarkMode = currentBrightness == Brightness.dark;

    final Color appBarBackgroundColor = isDarkMode ? Colors.teal.shade700 : Colors.teal;
    final Color appBarTextColor = Colors.white;
    final Color scaffoldBackgroundColor = isDarkMode ? Colors.black : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('User Feedbacks'),
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarTextColor, // For title and icons
        elevation: 2.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feedbacks',
            onPressed: _isLoading ? null : _fetchFeedbacks,
          )
        ],
      ),
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    final Color cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color iconColor = isDarkMode ? Colors.tealAccent.shade100 : Colors.teal;


    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: iconColor));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: subTextColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _fetchFeedbacks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_feedbacks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 80),
              const SizedBox(height: 20),
              Text(
                'No feedbacks yet.',
                style: TextStyle(fontSize: 20, color: textColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Check back later for user submissions.',
                style: TextStyle(fontSize: 16, color: subTextColor),
                textAlign: TextAlign.center,
              ),
               const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Feedbacks'),
                onPressed: _fetchFeedbacks,
                 style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFeedbacks,
      color: iconColor,
      backgroundColor: cardColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final feedback = _feedbacks[index];
          // Date formatting
          final String formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(feedback.createdAt.toLocal());

          return Card(
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedback.content,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Received: $formattedDate',
                      style: TextStyle(fontSize: 12, color: subTextColor, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
