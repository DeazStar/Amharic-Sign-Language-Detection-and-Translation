// lib/features/sign_translation/data/datasources/sign_translation_remote_datasource.dart

import 'dart:io'; // For File type
import '../../../../core/utils/input_type.dart'; // Enum for Video/Photo
import '../models/translation_result_model.dart'; // The DTO model

abstract class SignTranslationRemoteDataSource {

  Future<TranslationResultModel> translateFromFile({
    required File file,
    required InputType inputType,
  });
}
