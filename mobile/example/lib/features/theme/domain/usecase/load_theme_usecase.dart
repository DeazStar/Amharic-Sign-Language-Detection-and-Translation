// core/theme/domain/usecases/load_theme.dart


import 'package:camera_app/lib/features/theme/domain/entity/app_theme_entity.dart';
import 'package:camera_app/lib/features/theme/domain/repository/app_theme_entity.dart';

class LoadTheme {
  final ThemeRepository repository;

  LoadTheme(this.repository);

  Future<AppThemeEntity> call() async {
    return await repository.loadTheme() ?? AppThemeEntity.system;
  }
}
