// core/theme/domain/repositories/theme_repository.dart



import 'package:camera_app/features/theme/domain/entity/app_theme_entity.dart';

abstract class ThemeRepository {
  Future<void> saveTheme(AppThemeEntity theme);
  Future<AppThemeEntity?> loadTheme();

  Future<void> saveFontSize(double size);
  Future<double?> loadFontSize();
}
