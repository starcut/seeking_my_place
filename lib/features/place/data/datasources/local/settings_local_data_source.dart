import 'package:shared_preferences/shared_preferences.dart';

/// runApp 前に [initialize] を await することで、以降は同期的に取得できる。
class SharedPreferencesSingleton {
  SharedPreferencesSingleton._();

  static SharedPreferences? _instance;

  static Future<void> initialize() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'SharedPreferencesSingleton は未初期化です。'
        'runApp() の前に SharedPreferencesSingleton.initialize() を await してください。',
      );
    }
    return i;
  }
}

abstract class SettingsLocalDataSource {
  Map<String, dynamic> read();
  Future<void> write(Map<String, dynamic> data);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const keySearchRange = 'search_range';
  static const keyIsSearchEnabled = 'is_search_enabled';
  static const keyItemsPerPage = 'items_per_page';

  static const _defaultSearchRange = 10.0;
  static const _defaultIsSearchEnabled = true;
  static const _defaultItemsPerPage = 50;

  final SharedPreferences _prefs;

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  Map<String, dynamic> read() {
    return {
      keySearchRange: _prefs.getDouble(keySearchRange) ?? _defaultSearchRange,
      keyIsSearchEnabled:
          _prefs.getBool(keyIsSearchEnabled) ?? _defaultIsSearchEnabled,
      keyItemsPerPage: _prefs.getInt(keyItemsPerPage) ?? _defaultItemsPerPage,
    };
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    final searchRange = data[keySearchRange];
    final isSearchEnabled = data[keyIsSearchEnabled];
    final itemsPerPage = data[keyItemsPerPage];

    if (searchRange == null) {
      throw ArgumentError.notNull(keySearchRange);
    }
    if (searchRange is! double) {
      throw ArgumentError.value(searchRange, keySearchRange, 'double required');
    }

    if (isSearchEnabled == null) {
      throw ArgumentError.notNull(keyIsSearchEnabled);
    }
    if (isSearchEnabled is! bool) {
      throw ArgumentError.value(
        isSearchEnabled,
        keyIsSearchEnabled,
        'bool required',
      );
    }

    if (itemsPerPage == null) {
      throw ArgumentError.notNull(keyItemsPerPage);
    }
    if (itemsPerPage is! int) {
      throw ArgumentError.value(itemsPerPage, keyItemsPerPage, 'int required');
    }

    await _prefs.setDouble(keySearchRange, searchRange);
    await _prefs.setBool(keyIsSearchEnabled, isSearchEnabled);
    await _prefs.setInt(keyItemsPerPage, itemsPerPage);
  }
}
