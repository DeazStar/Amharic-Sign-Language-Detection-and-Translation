// lib/features/sign_translation/presentation/bloc/sign_translation_bloc.dart

import 'dart:async';
import 'dart:io'; // For File type in event handler
import 'package:bloc/bloc.dart'; // Core BLoC package
import 'package:camera_app/core/error/failure.dart';
import 'package:meta/meta.dart'; // For @required

// Import events and states
import 'sign_translation_event.dart';
import 'sign_translation_state.dart';

// Import the domain use case
import '../../domain/usecases/translate_sign_usecase.dart';
import '../../../../core/utils/input_type.dart'; // For InputType in event handler

/// BLoC (Business Logic Component) for handling sign language translation.
///
/// This BLoC manages the state of the translation feature, responding to
/// UI events and interacting with the [TranslateSignUseCase] to perform
/// the translation.
class SignTranslationBloc extends Bloc<SignTranslationEvent, SignTranslationState> {
  /// The use case responsible for executing the translation business logic.
  final TranslateSignUseCase translateSignUseCase;

  /// Constructor for the SignTranslationBloc.
  ///
  /// Requires an instance of [TranslateSignUseCase].
  /// Sets the initial state to [SignTranslationInitial].
  SignTranslationBloc({required this.translateSignUseCase}) : super(SignTranslationInitial()) {
    // Register event handlers
    on<TranslateSignFileEvent>(_onTranslateSignFileEvent);
    on<ResetSignTranslationEvent>(_onResetSignTranslationEvent);
  }

  /// Handles the [TranslateSignFileEvent].
  ///
  /// This method is called when a translation is requested.
  /// It emits [SignTranslationLoading], then calls the use case,
  /// and finally emits either [SignTranslationSuccess] or [SignTranslationFailure].
  Future<void> _onTranslateSignFileEvent(
    TranslateSignFileEvent event,
    Emitter<SignTranslationState> emit,
  ) async {
    // Emit loading state to notify UI that translation is in progress
    emit(SignTranslationLoading());

    // Prepare parameters for the use case
    final params = TranslateSignParams(file: event.file, inputType: event.inputType);

    // Execute the use case
    final failureOrTranslationResult = await translateSignUseCase(params);

    // Handle the result from the use case
    failureOrTranslationResult.fold(
      (failure) {
        // If there's a failure, emit SignTranslationFailure with an error message
        // You might want to map specific Failure types to more user-friendly messages
        String errorMessage = 'An unknown error occurred.';
        if (failure is ServerFailure) {
          errorMessage = failure.message ?? 'Server error during translation.';
        } else if (failure is LocalStorageFailure) { // Example if you had other failure types
            errorMessage = failure.message ?? 'Storage error during translation.';
        }
        // You can add more specific failure handling here
        emit(SignTranslationFailure(message: errorMessage));
      },
      (translationResult) {
        // If successful, emit SignTranslationSuccess with the result
        emit(SignTranslationSuccess(translationResult: translationResult));
      },
    );
  }

  /// Handles the [ResetSignTranslationEvent].
  ///
  /// This method resets the BLoC to its initial state.
  Future<void> _onResetSignTranslationEvent(
      ResetSignTranslationEvent event,
      Emitter<SignTranslationState> emit,
  ) async {
    emit(SignTranslationInitial());
  }
}
