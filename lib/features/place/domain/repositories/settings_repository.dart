import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';

// 1. partを追加
part 'settings_repository.g.dart';

abstract class SettingsRepository {
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
}

// 2. プロバイダーを定義
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  // ここで実際の実装クラス（SettingsRepositoryImplなど）を返す必要があります。
  // まだ実装がない場合は throw UnimplementedError() でOKです。
  throw UnimplementedError('SettingsRepositoryの実装クラスが登録されていません');
}
