import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';
import 'package:seeking_my_place/features/place/domain/repositories/settings_repository.dart';

part 'update_app_settings_use_case.g.dart';

@riverpod
class UpdateAppSettingsUseCase extends _$UpdateAppSettingsUseCase {
  @override
  FutureOr<void> build() {}

  Future<void> execute(AppSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).save(settings),
    );
  }
}
