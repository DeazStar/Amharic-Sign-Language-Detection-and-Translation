// lib/features/sign_translation/presentation/bloc/sign_translation_event.dart

import 'dart:io'; // For File type
import 'package:equatable/equatable.dart';
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo

/// Base class for all events related to sign language translation.
/// Extending Equatable allows for easy comparison of event instances.
abstract class SignTranslationEvent extends Equatable {
  const SignTranslationEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user initiates a translation process.
///
/// This event carries the [file] to be translated and its [inputType]
/// (either video or photo).
class TranslateSignFileEvent extends SignTranslationEvent {
  /// The file (image or video) selected by the user for translation.
  final File file;

  /// The type of the input file (e.g., video, photo).
  final InputType inputType;

  const TranslateSignFileEvent({required this.file, required this.inputType});

  @override
  List<Object?> get props => [file, inputType];
}

/// Event to reset the BLoC to its initial state.
/// This might be useful if the user wants to clear the previous translation
/// or navigate away and back to the translation screen.
class ResetSignTranslationEvent extends SignTranslationEvent {}
