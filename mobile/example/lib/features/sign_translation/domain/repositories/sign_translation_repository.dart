// lib/features/sign_translation/domain/repositories/sign_translation_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart'; 

// Assuming these are defined in your core directory
import '../../../../core/error/failure.dart'; // Base Failure class
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo

import '../entities/translation_result.dart'; // The domain entity

abstract class SignTranslationRepository {

  Future<Either<Failure, TranslationResult>> translateFromFile({
    required File file,
    required InputType inputType,
  });


}
