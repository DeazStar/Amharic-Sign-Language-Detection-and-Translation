import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/feedback_model.dart';


class FeedbackRemoteDataSource {
  final http.Client client;

  FeedbackRemoteDataSource({required this.client});

  Future<bool> sendFeedback(FeedbackModel feedback) async {
    
    final response = await client.post(
      Uri.parse('http://18.188.141.168:8000/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(feedback.toJson()),
    );
    return response.statusCode == 200;
  }
}
