// lib/features/sign_translation/domain/entities/translation_result.dart

import 'package:equatable/equatable.dart';

/// Represents the core result of a sign language translation.
/// This entity encapsulates the essential data returned after a successful translation.
/// It remains independent of the data source (API) and the presentation layer (UI).
class TranslationResult extends Equatable {
  /// The text generated from the sign language input (image or video).
  final String translatedText;

  

  /// Constructor for the TranslationResult.
  const TranslationResult({
    required this.translatedText,
   // Make it optional if the backend might not always return it
  });

  /// Overriding props for value comparison using the Equatable package.
  /// This helps in comparing two instances of TranslationResult.
  @override
  List<Object?> get props => [translatedText];
}
