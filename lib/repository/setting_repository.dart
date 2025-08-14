import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/purpose_list_service.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  return SettingRepository(service: ref.read(purposeListControllerProvider));
});

class SettingRepository {
  final PurposeListService service;
  SettingRepository({required this.service});

  Future<void> initDatabase() async {
    try {
      final data = await service.initDatabaseExecute();
      return data;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<List<PurposeEntity>> selectAll() async {
    try {
      initDatabase();
      final data = await service.selectAllExecute();
      return data;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<PurposeEntity?> selectPurposeDataById(int id) async {
    try {
      initDatabase();
      final data = await service.selectPurposeDataByIdExecute(id);
      debugPrint("select by id: ${data?.purposeText}");
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository selectAll error");
      throw Exception(exception);
    }
  }

  Future<void> insertPurposeData(String purposeName) async {
    try {
      final data = await service.insertPurposeDataExecute(purposeName);
      return data;
    } on Exception catch (exception) {
      debugPrint("SettingRepository insertPurposeData error");
      throw Exception(exception);
    }
  }

  Future<void> updatePurposeData(PurposeEntity entity) async {
    try {
      initDatabase();
      await service.updatePurposeDataExecute(entity);
    } on Exception catch (exception) {
      debugPrint("SettingRepository updatePurposeData error");
      throw Exception(exception);
    }
  }

  Future<void> deletePurposeData(int id) async {
    try {
      await service.deletePurposeDataExecute(id);
    } on Exception catch (exception) {
      debugPrint("SettingRepository deletePurposeData error");
      throw Exception(exception);
    }
  }
}
