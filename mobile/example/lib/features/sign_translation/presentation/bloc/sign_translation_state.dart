// lib/features/sign_translation/presentation/bloc/sign_translation_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/translation_result.dart'; // The domain entity

/// Base class for all states related to sign language translation.
/// Extending Equatable allows for easy comparison of state instances,
/// which is useful for BLoC to determine if the UI needs to rebuild.
abstract class SignTranslationState extends Equatable {
  const SignTranslationState();

  @override
  List<Object?> get props => [];
}

/// The initial state of the feature before any translation is attempted
/// or after a reset.
class SignTranslationInitial extends SignTranslationState {}

/// State indicating that the translation process is currently in progress.
/// The UI would typically show a loading indicator in this state.
class SignTranslationLoading extends SignTranslationState {}

/// State indicating that the translation was successful.
/// It holds the [translationResult] obtained from the use case.
class SignTranslationSuccess extends SignTranslationState {
  final TranslationResult translationResult;

  const SignTranslationSuccess({required this.translationResult});

  @override
  List<Object?> get props => [translationResult];
}

/// State indicating that an error occurred during the translation process.
/// It holds an error [message] to be displayed to the user.
class SignTranslationFailure extends SignTranslationState {
  final String message;

  const SignTranslationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
