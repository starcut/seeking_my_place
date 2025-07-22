import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/repository/setting_repository.dart';

final settingViewModelNotifierProvider =
    FutureProvider<List<PurposeEntity>>((ref) async {
  final viewModel =
      SettingViewModel(repository: ref.read(settingRepositoryProvider));
  await viewModel.selectAll();
  return viewModel.purposeList;
});

final settingViewModelSelectByIdNotifierProvider =
    StateNotifierProvider<PurposeData, List<PurposeEntity>>((ref) {
  return PurposeData(ref);
});

class PurposeData extends StateNotifier<List<PurposeEntity>> {
  PurposeData(this.ref) : super(<PurposeEntity>[]);

  final Ref ref;

  Future<PurposeEntity?> getPurposeList(int id) {
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
  final SettingRepository repository;

  SettingViewModel({required this.repository});

  late List<PurposeEntity> _purposeList;
  List<PurposeEntity> get purposeList => _purposeList;

  late PurposeEntity? _purposeData;
  PurposeEntity? get purposeData => _purposeData;

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
          "_purposeData: ${_purposeData?.purposeName}");
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
