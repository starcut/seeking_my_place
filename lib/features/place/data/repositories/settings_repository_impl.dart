import 'package:seeking_my_place/features/place/data/datasources/local/settings_local_data_source.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';
import 'package:seeking_my_place/features/place/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<AppSettings> get() async {
    final data = await _dataSource.read();

    return AppSettings(
      searchRange:
          data[SettingsLocalDataSourceImpl.keySearchRange] as double,
      isSearchEnabled:
          data[SettingsLocalDataSourceImpl.keyIsSearchEnabled] as bool,
      itemsPerPage:
          data[SettingsLocalDataSourceImpl.keyItemsPerPage] as int,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _dataSource.write({
      SettingsLocalDataSourceImpl.keySearchRange: settings.searchRange,
      SettingsLocalDataSourceImpl.keyIsSearchEnabled: settings.isSearchEnabled,
      SettingsLocalDataSourceImpl.keyItemsPerPage: settings.itemsPerPage,
    });
  }
}
