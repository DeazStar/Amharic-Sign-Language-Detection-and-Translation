import 'package:camera_app/lib/features/theme/domain/repository/app_theme_entity.dart';

class SaveFontSize {
  final ThemeRepository repository;
  SaveFontSize(this.repository);

  Future<void> call(double size) => repository.saveFontSize(size);
}