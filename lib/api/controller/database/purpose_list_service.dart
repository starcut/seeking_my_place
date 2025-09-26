import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/database/database_manager.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final purposeListControllerProvider =
    Provider<PurposeListService>((ref) => PurposeListService());

class PurposeListService {
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
      List<Map<String, Object?>> records = await DatabaseManager.shared.database
          .rawQuery('SELECT * FROM ${DatabaseManager.shared.masterTableNamePurpose}'
          ' WHERE ${DatabaseManager.shared.columnMasterPurposeId} = ${id}');
      PurposeEntity selectedPurposeData = PurposeEntity.fromMap(records.first);
      debugPrint(
          "update ${DatabaseManager.shared.columnMasterPurposeId}: ${selectedPurposeData.id} "
              "${DatabaseManager.shared.columnMasterPurposeName}: ${selectedPurposeData.purposeName}");
      return selectedPurposeData;
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase $exception");
      Exception(exception);
      return null;
    }
  }

  Future<void> insertPurposeDataExecute(String purposeName) async {
    try {
      debugPrint("insertPurposeDataExecute start");
      await DatabaseManager.shared.database.transaction((txn) async {
        final sql = 'INSERT INTO ${DatabaseManager.shared.masterTableNamePurpose} '
            '(${DatabaseManager.shared.columnMasterPurposeName}) '
            'VALUES '
            '("$purposeName")';
        print(sql);
        await txn.rawInsert(sql);
      });
    } on Exception catch (exception) {
      debugPrint("PurposeListController insertPurposeData $exception");
      Exception(exception);
    }
  }

  Future<void> updatePurposeDataExecute(PurposeEntity entity) async {
    try {
      await DatabaseManager.shared.database.rawUpdate(
          'UPDATE ${DatabaseManager.shared.masterTableNamePurpose}'
              ' SET ${DatabaseManager.shared.columnMasterPurposeName} = ?,'
              ' WHERE ${DatabaseManager.shared.columnMasterPurposeId} = ?',
          [entity.purposeName, DateTime.now().toString(), entity.id]);
    } on Exception catch (exception) {
      debugPrint("PurposeListController updatePurposeDataExecute error");
      Exception(exception);
    }
  }

  Future<void> deletePurposeDataExecute(int id) async {
    try {
      final sql = 'DELETE FROM ${DatabaseManager.shared.masterTableNamePurpose} '
          'WHERE ${DatabaseManager.shared.columnMasterPurposeId} = $id';
      await DatabaseManager.shared.database.rawDelete(sql);
    } on Exception catch (exception) {
      debugPrint("PurposeListController deletePurposeDataExecute error");
      Exception(exception);
    }
  }
}
