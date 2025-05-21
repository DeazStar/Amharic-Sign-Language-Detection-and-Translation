// lib/features/sign_translation/data/datasources/sign_translation_remote_datasource_impl.dart

import 'dart:convert'; // For jsonDecode
import 'dart:io'; // For File type
import 'package:http/http.dart' as http; // Using the http package
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:meta/meta.dart'; // For @required

// Assuming these are defined in your core directory
import '../../../../core/error/exceptions.dart'; // Custom exceptions (e.g., ServerException)
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo

import '../models/translation_result_model.dart'; // The DTO model
import 'sign_translation_remote_datasource.dart'; // The abstract class we are implementing

/// Concrete implementation of [SignTranslationRemoteDataSource] using the `http` package.
class SignTranslationRemoteDataSourceImpl implements SignTranslationRemoteDataSource {
  final http.Client client; // Injecting the HTTP client for testability

  // Define your base API URL - move this to a config file ideally
  final String baseUrl = "http://192.168.205.226:8000"; // <-- REPLACE WITH YOUR ACTUAL BASE URL

  SignTranslationRemoteDataSourceImpl({required this.client});

  @override
  Future<TranslationResultModel> translateFromFile({
    required File file,
    required InputType inputType,
  }) async {
    // Determine the correct endpoint based on the input type
    final String endpoint = inputType == InputType.video ? '/process-video' : '/process-image/';
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    try {
      // Create a multipart request to send the file
      final request = http.MultipartRequest('POST', uri);

      // Attach the file to the request
      // The field name 'file', 'video', or 'image' depends on your backend API specification
      const String fieldName = 'file'; // <-- ADJUST FIELD NAME AS NEEDED
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        // You might need to specify contentType depending on your backend
        contentType: MediaType('image', 'jpeg'),
      ));

      print("Hello there I am sending a post request");
      print(request);


      // Send the request and get the response
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      print("responseeeeeeeeeeeeeee");
      print(response.body); // Log the response for debugging

      // Check the response status code
      if (response.statusCode == 200) {
        // If successful (200 OK), parse the JSON response body
        final Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        // Convert the JSON map to our TranslationResultModel
        return TranslationResultModel.fromJson(jsonMap);
      } else {
        // If the server returned an error status code (4xx, 5xx), throw a ServerException
        // You might want to parse the error message from response.body if available
        throw ServerException(statusCode: response.statusCode, message: response.body);
      }
    } on SocketException {
       // Handle network errors (no internet connection)
       throw const ServerException(message: 'Notntntnt Internet Connection');
    } on FormatException catch (e) {
      // Handle errors during JSON parsing (invalid format from backend)
      throw ServerException(message: 'Invalid response format from server: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors during the HTTP request
      print('Unexpected error in remote data source: $e'); // Log the error
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}



/// Custom Exception for local cache errors (if you had a local data source).
// class CacheException implements Exception {
//   final String? message;
//   const CacheException({this.message});
// }
