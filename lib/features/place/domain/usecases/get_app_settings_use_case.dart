import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/app_settings.dart';
import 'package:seeking_my_place/features/place/domain/repositories/settings_repository.dart';

part 'get_app_settings_use_case.g.dart';

@riverpod
AppSettings getAppSettingsUseCase(Ref ref) {
  return ref.read(settingsRepositoryProvider).get();
}
