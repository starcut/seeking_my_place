import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';
import 'package:seeking_my_place/features/place/domain/repositories/settings_repository.dart';

part 'observe_app_settings_use_case.g.dart';

@Riverpod(keepAlive: true)
class ObserveAppSettingsUseCase extends _$ObserveAppSettingsUseCase {
  @override
  AppSettings build() {
    return ref.read(settingsRepositoryProvider).get();
  }

  Future<void> update(AppSettings settings) async {
    await ref.read(settingsRepositoryProvider).save(settings);
    state = ref.read(settingsRepositoryProvider).get();
  }

  /// searchRange のみを更新する。他のフィールドは現在の設定値を引き継ぐ。
  Future<void> updateSearchRange(double searchRange) async {
    await update(state.copyWith(searchRange: searchRange));
  }
}
