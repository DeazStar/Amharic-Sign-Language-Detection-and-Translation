// lib/features/sign_translation/data/models/translation_result_model.dart

import '../../domain/entities/translation_result.dart'; // Import the domain entity

class TranslationResultModel extends TranslationResult {

  const TranslationResultModel({
    required String translatedText,
    // String? audioBase64, // Keep it nullable to match the entity
  }) : super(translatedText: translatedText);


  /// }
  factory TranslationResultModel.fromJson(Map<String, dynamic> json) {
    // Perform validation to ensure the expected key exists and is a string.
    if (json.containsKey('prediction') && json['prediction'] is String) {
      return TranslationResultModel(
        translatedText: json['prediction'] as String,
        // Check if 'audio_base64' exists and is a string before assigning
        // audioBase64: json.containsKey('audio') && json['audio'] is String
        //     ? json['audio'] as String
        //     : null, // Assign null if not present or not a string
      );
    } else {
      // Throw an exception if the JSON format is invalid for the required fields.
      throw const FormatException(
          'Invalid JSON format for TranslationResultModel: missing or invalid translated_text');
    }
  }

  /// Converts the [TranslationResultModel] instance to a JSON map.
  /// This might be useful if you needed to send this model back to an API
  /// or store it locally.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'translated_text': translatedText,
    };
    // Only include audio_base64 in JSON if it's not null
    // if (audioBase64 != null) {
    //   data['audio_base64'] = audioBase64;
    // }
    return data;
  }
}
