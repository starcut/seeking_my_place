import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/provider/purpose_list_controller_provider.dart';
import 'package:seeking_my_place/repository/interface/setting_repository_impl.dart';
import 'package:seeking_my_place/repository/setting_repository.dart';

final settingRepositoryProvider = Provider<SettingRepositoryImpl>((ref) {
  return SettingRepository(repository: ref.read(purposeListControllerProvider));
});
