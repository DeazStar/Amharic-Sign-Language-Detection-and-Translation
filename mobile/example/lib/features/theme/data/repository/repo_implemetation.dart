// core/theme/data/repositories_impl/theme_repository_impl.dart

import 'package:camera_app/lib/features/theme/data/data_source/theme_local_datasource.dart';
import 'package:camera_app/lib/features/theme/data/model/theme_model.dart';
import 'package:camera_app/lib/features/theme/domain/entity/app_theme_entity.dart';
import 'package:camera_app/lib/features/theme/domain/repository/app_theme_entity.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;

  ThemeRepositoryImpl(this.localDataSource);

  @override
  Future<void> saveTheme(AppThemeEntity theme) async {
    await localDataSource.cacheTheme(ThemeModel.toStorage(theme));
  }

  @override
  Future<AppThemeEntity?> loadTheme() async {
    final value = await localDataSource.getCachedTheme();
    return value == null ? null : ThemeModel.fromStorage(value);
  }

  @override
  Future<void> saveFontSize(double size) =>
      localDataSource.cacheFontSize(size);

  @override
  Future<double?> loadFontSize() =>
      localDataSource.getCachedFontSize();
}
