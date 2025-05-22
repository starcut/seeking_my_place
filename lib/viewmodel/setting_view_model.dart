import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/setting_model.dart';
import 'package:seeking_my_place/repository/interface/setting_repository_impl.dart';
import 'package:seeking_my_place/repository/setting_repository.dart';

final settingViewModelNotifierProvider =
    FutureProvider<SettingModel>((ref) async {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  await viewModel.selectAll();
  return viewModel.purposeList;
});

final settingViewModelSelectByIdNotifierProvider =
    StateNotifierProvider<PurposeData, SettingModel>((ref) {
  return PurposeData(ref);
});

class PurposeData extends StateNotifier<SettingModel> {
  PurposeData(this.ref) : super(SettingModel());

  final Ref ref;

  Future<SettingModel> getPurposeList(int id) {
    final repository = ref.read(settingRepositoryProvider);
    final settingModel = repository.selectPurposeDataById(id);
    return settingModel;
  }
}

final settingViewModelInsertDataProvider =
    Provider.family<void, String>((ref, purposeName) {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  viewModel.insertPurposeData(purposeName);
});

final settingViewModelUpdateDataProvider =
    Provider.family<void, PurposeEntity>((ref, entity) {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  viewModel.updatePurposeData(entity);
});

final settingViewModelDeleteDataProvider =
    Provider.family<void, int>((ref, id) {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  viewModel.deletePurposeData(id);
});

class SettingViewModel {
  final SettingRepositoryImpl repository;

  SettingViewModel({required this.repository});

  late SettingModel _purposeList;
  SettingModel get purposeList => _purposeList;

  late SettingModel _purposeData;
  SettingModel get purposeData => _purposeData;

  bool isLoading = false;

  Future selectAll() async {
    try {
      await repository.initDatabase();
      _purposeList = await repository.selectAll();
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future selectById(int id) async {
    try {
      debugPrint("selectById(id: $id) start");
      _purposeData = await repository.selectPurposeDataById(id);
      debugPrint(
          "_purposeData: ${_purposeData.selectedPurposeData.purposeName}");
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future insertPurposeData(String purposeName) async {
    try {
      await repository.insertPurposeData(purposeName);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future updatePurposeData(PurposeEntity entity) async {
    try {
      await repository.updatePurposeData(entity);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future deletePurposeData(int id) async {
    try {
      await repository.deletePurposeData(id);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }
}
