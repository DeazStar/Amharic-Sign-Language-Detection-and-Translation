// lib/features/text_to_speech/data/datasources/tts_remote_datasource.dart
import 'dart:typed_data';
import 'package:flutter/material.dart'; // For @required and debugPrint
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode, jsonDecode, utf8, base64Decode
import '../../../../core/error/exceptions.dart'; // Assuming ServerException exists
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Google Cloud TTS Configuration ---
// WARNING: The access token below is short-lived and should NOT be hardcoded in production.
// You will need to refresh it frequently for testing.
// For production, use a proper server-side authentication method or API keys with restrictions.
const String _googleCloudAccessToken = "ya29.a0AW4XtxjeaYa3fTIv0K5qCCUIlGcby2aPuRh4z6tElde1wjlbEuaFvQEMSYIB4QEN2CDNVqWHIxNQLnUtvA4n9KrQ_po1GOBTOMc3f59jZRNLTbshEgaciTNfS84n1KsrOGvPqsKmqvzKgKRtRG4vb0s-2OlyF_t9o1xvUWZm35WplAaCgYKAYkSARESFQHGX2MiStlbDL7bsW3RZEUFEP7kdg0181"; // YOUR SHORT-LIVED ACCESS TOKEN
const String _googleCloudProjectId = "striped-botany-461100-c3"; // YOUR PROJECT ID

const String _googleCloudTtsEndpoint = "https://texttospeech.googleapis.com/v1/text:synthesize";
// Desired audio output format for Google Cloud TTS
const String _googleCloudAudioEncoding = "MP3"; // Options: "MP3", "LINEAR16", "OGG_OPUS"


abstract class TtsRemoteDataSource {
  Future<Uint8List> fetchTtsAudio({
    required String text,
    required String languageCode, // e.g., "am-ET"
    required String voiceName,    // e.g., "am-ET-Standard-A" or "am-ET-Wavenet-A"
  });
}

class TtsRemoteDataSourceImpl implements TtsRemoteDataSource {
  final http.Client client;

  TtsRemoteDataSourceImpl({required this.client});

  @override
  Future<Uint8List> fetchTtsAudio({
    required String text,
    required String languageCode,
    required String voiceName,
  }) async {
    // Basic check for placeholder values
    if (_googleCloudAccessToken.startsWith("ya29.a0A") && _googleCloudAccessToken.length < 20) { // Basic check, not a real validation
        debugPrint("Warning: Google Cloud Access Token might be a placeholder or too short.");
    }
    if (_googleCloudProjectId.contains("YOUR_PROJECT_ID") || _googleCloudProjectId.isEmpty) {
      throw const ServerException(message: "Google Cloud Project ID is not configured.");
    }

    final headers = {
      "Authorization": "Bearer $_googleCloudAccessToken",
      "X-Goog-User-Project": _googleCloudProjectId,
      "Content-Type": "application/json; charset=utf-8", // Specify charset for request body
    };

    // Construct JSON body for Google Cloud TTS (using text input, not SSML for this example)
    final requestBody = {
      "input": {
        "text": text
      },
      "voice": {
        "languageCode": languageCode,
        "name": voiceName
        // "ssmlGender": "NEUTRAL" // Optional: You can add other voice params
      },
      "audioConfig": {
        "audioEncoding": _googleCloudAudioEncoding
        // "sampleRateHertz": 16000, // Optional: if LINEAR16, specify sample rate
        // "speakingRate": 1.0, // Optional
        // "pitch": 0.0 // Optional
      }
    };

    debugPrint("Google Cloud TTS Request:");
    debugPrint("  Endpoint: $_googleCloudTtsEndpoint");
    debugPrint("  Headers: Authorization=Bearer [TOKEN_HIDDEN], X-Goog-User-Project=$_googleCloudProjectId, Content-Type=${headers['Content-Type']}");
    debugPrint("  Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await client.post(
        Uri.parse(_googleCloudTtsEndpoint),
        headers: headers,
        body: jsonEncode(requestBody), // Body is JSON encoded
      );

      debugPrint("Google Cloud TTS Response Status Code: ${response.statusCode}");
      // debugPrint("Google Cloud TTS Response Body: ${response.body}");


      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        if (responseJson.containsKey('audioContent') && responseJson['audioContent'] is String) {
          final String audioBase64 = responseJson['audioContent'];
          if (audioBase64.isEmpty) {
            debugPrint("Google Cloud TTS Response: Received empty 'audioContent'.");
            throw const ServerException(message: "Received empty audio content from Google Cloud TTS.");
          }
          // Decode base64 string to Uint8List
          final Uint8List audioBytes = base64Decode(audioBase64);
          debugPrint("Google Cloud TTS Response: Decoded ${audioBytes.lengthInBytes} bytes of audio data.");
          return audioBytes;
        } else {
          debugPrint("Google Cloud TTS Response: 'audioContent' field missing or not a string in response.");
          throw const ServerException(message: 'text_to_speech translation failed');
        }
      } else {
        String errorMessage = "Google Cloud TTS API Error: ${response.statusCode}";
        String responseBodyString = response.body;
        
        if (responseBodyString.isNotEmpty) {
            try {
                 final errorDetails = json.decode(responseBodyString);
                 // Google Cloud error structure is often: { "error": { "code": ..., "message": ..., "status": ... } }
                 errorMessage += " - ${errorDetails['error']?['message'] ?? responseBodyString}";
            } catch (_){
                 errorMessage += " - Details: ${responseBodyString.length > 200 ? responseBodyString.substring(0, 200) + "..." : responseBodyString}";
            }
        }
        debugPrint(errorMessage);
        debugPrint("Full Google Cloud TTS Error Response Body: $responseBodyString");
        throw ServerException(statusCode: response.statusCode, message: 'text to speech conversion failed. Please try again!');
      }
    } on http.ClientException catch(e) { 
        debugPrint("HTTP Client Exception during Google TTS request: $e");
        throw ServerException(message: "Network error during Text_to_speech conversion request");
    } catch (e, s) {
      debugPrint("Unexpected error fetching Google TTS audio: $e\nStack: $s");
      throw ServerException(message: "Unexpected error during text to speech conversion request");
    }
  }
}