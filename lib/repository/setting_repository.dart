import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/purpose_list_controller.dart';
import 'package:seeking_my_place/api/controller/purpose_list_controller_impl.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/setting_model.dart';
import 'package:seeking_my_place/repository/interface/setting_repository_impl.dart';

final settingRepositoryProvider = Provider<SettingRepositoryImpl>((ref) {
  return SettingRepository(repository: ref.read(purposeListControllerProvider));
});

class SettingRepository implements SettingRepositoryImpl {
  final PurposeListControllerImpl repository;
  SettingRepository({required this.repository});

  @override
  Future<void> initDatabase() async {
    try {
      final data = await repository.initDatabaseExecute();
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository initDatabase error");
      throw Exception(exception);
    }
  }

  @override
  Future<SettingModel> selectAll() async {
    try {
      initDatabase();
      debugPrint("SettingRepository selectAll() start");
      final data = await repository.selectAllExecute();
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository selectAll error");
      throw Exception(exception);
    }
  }

  @override
  Future<SettingModel> selectPurposeDataById(int id) async {
    try {
      initDatabase();
      debugPrint("SettingRepository selectPurposeDataById() start");
      final data = await repository.selectPurposeDataByIdExecute(id);
      debugPrint("select by id: ${data.selectedPurposeData.purposeName}");
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository selectAll error");
      throw Exception(exception);
    }
  }

  @override
  Future<void> insertPurposeData(String purposeName) async {
    try {
      debugPrint("SettingRepository insertPurposeData start");
      final data = await repository.insertPurposeDataExecute(purposeName);
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository insertPurposeData error");
      throw Exception(exception);
    }
  }

  @override
  Future<void> updatePurposeData(PurposeEntity entity) async {
    try {
      initDatabase();
      await repository.updatePurposeDataExecute(entity);
    } on Exception catch (exception) {
      debugPrint("SettingRepository updatePurposeData error");
      throw Exception(exception);
    }
  }

  @override
  Future<void> deletePurposeData(int id) async {
    try {
      await repository.deletePurposeDataExecute(id);
    } on Exception catch (exception) {
      debugPrint("SettingRepository deletePurposeData error");
      throw Exception(exception);
    }
  }
}
