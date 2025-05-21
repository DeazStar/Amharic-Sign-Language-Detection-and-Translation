import 'package:camera_app/features/theme/domain/repository/app_theme_entity.dart';

class LoadFontSize {
  final ThemeRepository repository;
  LoadFontSize(this.repository);

  Future<double> call() async =>
      await repository.loadFontSize() ?? 16.0; // default size
}