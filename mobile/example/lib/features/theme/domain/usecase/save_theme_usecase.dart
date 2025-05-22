// core/theme/domain/usecases/save_theme.dart
import 'package:camera_app/features/theme/domain/entity/app_theme_entity.dart';
import 'package:camera_app/features/theme/domain/repository/app_theme_entity.dart';


class SaveTheme {
  final ThemeRepository repository;

  SaveTheme(this.repository);

  Future<void> call(AppThemeEntity theme) => repository.saveTheme(theme);
}
