import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/model/setting_model.dart';
import 'package:seeking_my_place/repository/provider/setting_repository_provider.dart';
import 'package:seeking_my_place/viewmodel/setting_view_model.dart';

final settingViewModelNotifierProvider =
    FutureProvider<SettingModel>((ref) async {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  await viewModel.selectAll();
  return viewModel.purposeList;
});

final settingViewModelInsertDataProvider =
    Provider.family<void, String>((ref, purposeName) {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  viewModel.insertPurposeData(purposeName);
});
