import 'package:camera_app/features/theme/domain/entity/app_theme_entity.dart';
import 'package:camera_app/features/theme/domain/usecase/load_font_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/load_theme_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/save_font_usecase.dart';
import 'package:camera_app/features/theme/domain/usecase/save_theme_usecase.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  final LoadTheme loadThemeUseCase;
  final SaveTheme saveThemeUseCase;
  final LoadFontSize loadFontSizeUseCase;
  final SaveFontSize saveFontSizeUseCase;

  AppThemeEntity _appTheme = AppThemeEntity.system;
  double _fontSize = 16.0;

  AppThemeEntity get appTheme => _appTheme;
  double get fontSize => _fontSize;

  ThemeMode get themeMode {
    switch (_appTheme) {
      case AppThemeEntity.dark:
        return ThemeMode.dark;
      case AppThemeEntity.light:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeProvider({
    required this.loadThemeUseCase,
    required this.saveThemeUseCase,
    required this.loadFontSizeUseCase,
    required this.saveFontSizeUseCase,
  });

  Future<void> init() async {
    _appTheme = await loadThemeUseCase();
    _fontSize = await loadFontSizeUseCase();
    notifyListeners();
  }

  Future<void> toggle(bool isDark) async {
    _appTheme = isDark ? AppThemeEntity.dark : AppThemeEntity.light;
    await saveThemeUseCase(_appTheme);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await saveFontSizeUseCase(size);
    notifyListeners();
  }
}
