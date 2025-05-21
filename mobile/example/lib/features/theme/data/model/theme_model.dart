// core/theme/data/models/theme_model.dart
import 'package:camera_app/lib/features/theme/domain/entity/app_theme_entity.dart';


class ThemeModel {
  static String toStorage(AppThemeEntity theme) => theme.name;

  static AppThemeEntity fromStorage(String value) {
    switch (value) {
      case 'light':
        return AppThemeEntity.light;
      case 'dark':
        return AppThemeEntity.dark;
      default:
        return AppThemeEntity.system;
    }
  }
}
