import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  final SharedPreferences prefs;

  ThemeLocalDataSource(this.prefs);

  static const _themeKey = 'app_theme';
  static const _fontSizeKey = 'font_size';

  Future<void> cacheTheme(String themeValue) async {
    await prefs.setString(_themeKey, themeValue);
  }

  Future<String?> getCachedTheme() async {
    return prefs.getString(_themeKey);
  }

  Future<void> cacheFontSize(double size) async {
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<double?> getCachedFontSize() async {
    return prefs.getDouble(_fontSizeKey);
  }
}
