import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/database/database_manager.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:sqflite/sqflite.dart';

final purposeListControllerProvider =
    Provider<PurposeListService>((ref) => PurposeListService());

class PurposeListService {
  static late Database _database;

  Future<List<PurposeEntity>> selectAllExecute() async {
    debugPrint("selectAllExecute() start");
    List<PurposeEntity> purposeList = [];
    try {
      purposeList = await DatabaseManager.shared.selectAllPurposeMasterData();
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
    }

    return purposeList;
  }

  Future<PurposeEntity?> selectPurposeDataByIdExecute(int id) async {
    try {
      List<Map<String, Object?>> records = await PurposeListService._database
          .rawQuery('SELECT * FROM purpose_tag WHERE id = ${id}');
      PurposeEntity selectedPurposeData = PurposeEntity.fromMap(records.first);
      debugPrint(
          "update id: ${selectedPurposeData.id} name:${selectedPurposeData.purposeName}");
      return selectedPurposeData;
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
      return null;
    }
  }

  Future<void> insertPurposeDataExecute(String purposeName) async {
    try {
      debugPrint("insertPurposeDataExecute start");
      await PurposeListService._database.transaction((txn) async {
        await txn.rawInsert('INSERT INTO purpose_tag '
            '(purpose_name, register_at, updated_at) '
            'VALUES '
            '("$purposeName", "${DateTime.now().toString()}", "${DateTime.now().toString()}")');
      });
    } on Exception catch (exception) {
      debugPrint("PurposeListController insertPurposeData error");
      Exception(exception);
    }
  }

  Future<void> updatePurposeDataExecute(PurposeEntity entity) async {
    try {
      await PurposeListService._database.rawUpdate(
          'UPDATE purpose_tag SET purpose_name = ?, updated_at = ? WHERE id = ?',
          [entity.purposeName, DateTime.now().toString(), entity.id]);
    } on Exception catch (exception) {
      debugPrint("PurposeListController updatePurposeDataExecute error");
      Exception(exception);
    }
  }

  Future<int> deletePurposeDataExecute(int id) async {
    try {
      int deleteCount = await PurposeListService._database
          .rawDelete('DELETE FROM purpose_tag WHERE id = $id');
      return deleteCount;
    } on Exception catch (exception) {
      debugPrint("PurposeListController deletePurposeDataExecute error");
      Exception(exception);
      return 0;
    }
  }
}
