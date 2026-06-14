import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/settings_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/repositories/settings_repository_impl.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';

part 'settings_repository.g.dart';

abstract class SettingsRepository {
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final dataSource = SettingsLocalDataSourceImpl(
    SharedPreferencesSingleton.instance,
  );
  return SettingsRepositoryImpl(dataSource);
}
