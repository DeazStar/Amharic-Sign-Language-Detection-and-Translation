// lib/features/feedback/presentation/pages/feedback_list_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode

// Define a simple Feedback model (adjust based on your actual backend response)
class FeedbackItem {
  final String id; // Or int
  final String content;
  final DateTime createdAt; // Example field

  FeedbackItem({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id']?.toString() ?? 'unknown_id',
      content: json['feedback_text'] ?? json['message'] ?? 'No content', // Adjust keys
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(), // Adjust keys
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
  final String _feedbacksUrl = "http://18.188.141.168:8000/feedbacks";

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call
      final response = await http.get(
        Uri.parse(_feedbacksUrl),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      // Mocked response for now
      // await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _feedbacks = responseData.map((data) => FeedbackItem.fromJson(data)).toList();
      } else {
        _errorMessage = "Failed to load feedbacks. Status: ${response.statusCode}";
        _feedbacks = []; // Clear previous feedbacks on error
      }

      // --- MOCK ---
      // if (widget.accessToken == "mock_access_token_123") {
      //    _feedbacks = [
      //     FeedbackItem(id: "1", content: "Great app, very helpful!", userEmail: "user1@example.com", createdAt: DateTime.now().subtract(const Duration(days: 1))),
      //     FeedbackItem(id: "2", content: "The translation for 'hello' was a bit off.", userEmail: "user2@example.com", createdAt: DateTime.now().subtract(const Duration(hours: 5))),
      //     FeedbackItem(id: "3", content: "Love the UI, easy to use.", userEmail: "user3@example.com", createdAt: DateTime.now()),
      //   ];
      // } else {
      //   _errorMessage = "Failed to load feedbacks (mocked: invalid token)";
      //   _feedbacks = [];
      // }
      // --- END MOCK ---

    } catch (e) {
      debugPrint("Error fetching feedbacks: $e");
      _errorMessage = "An error occurred: $e";
      _feedbacks = []; // Clear previous feedbacks on error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Feedbacks'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _fetchFeedbacks, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No feedbacks found.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchFeedbacks, child: const Text('Refresh Feedbacks')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFeedbacks,
      child: ListView.builder(
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final feedback = _feedbacks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(child: Text((index + 1).toString())),
              title: Text(feedback.content),
              subtitle: Text('On: ${feedback.createdAt.toLocal().toString().substring(0, 16)}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
