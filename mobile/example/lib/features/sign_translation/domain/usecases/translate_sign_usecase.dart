// lib/features/sign_translation/domain/usecases/translate_sign.dart

import 'dart:io'; // Using dart:io File for simplicity
import 'package:dartz/dartz.dart'; // For Either
import 'package:equatable/equatable.dart'; // For Params class

// Assuming these are defined in your core directory
import '../../../../core/error/failure.dart'; // Base Failure class
import '../../../../core/usecase/usecase.dart'; // Base UseCase class
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo

import '../entities/translation_result.dart'; // The domain entity
import '../repositories/sign_translation_repository.dart'; // The repository contract

class TranslateSignUseCase implements UseCase<TranslationResult, TranslateSignParams> {

  final SignTranslationRepository repository;

  TranslateSignUseCase(this.repository);

  @override
  Future<Either<Failure, TranslationResult>> call(TranslateSignParams params) async {

    return await repository.translateFromFile(
      file: params.file,
      inputType: params.inputType,
    );
  }
}

/// Parameters required for the [TranslateSignUseCase].
///
/// Encapsulates the input data needed to execute the translation use case.
/// Using a dedicated Params class improves readability and maintainability,
/// especially if the number of parameters grows.
class TranslateSignParams extends Equatable {
  /// The file containing the sign language (image or video).
  final File file; // Or String path / Uint8List bytes for stricter purity

  /// The type of the input file.
  final InputType inputType;

  const TranslateSignParams({required this.file, required this.inputType});

  /// Overriding props for value comparison using Equatable.
  @override
  List<Object?> get props => [file, inputType];
}
