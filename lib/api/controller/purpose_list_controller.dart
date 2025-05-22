import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/model/setting_model.dart';
import 'package:seeking_my_place/api/controller/purpose_list_controller_impl.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:sqflite/sqflite.dart';

final purposeListControllerProvider =
    Provider<PurposeListControllerImpl>((ref) => PurposeListController());

class PurposeListController implements PurposeListControllerImpl {
  static late Database _database;
  static late String _databasePath;

  @override
  Future<void> initDatabaseExecute() async {
    try {
      var databasePath = await getDatabasesPath();
      await Directory(databasePath).create(recursive: true);
    } on Exception catch (exception) {
      debugPrint("database not exist");
      Exception(exception);
    }

    try {
      PurposeListController._database = await openDatabase(
        'seeking_place.db',
        version: 1,
        onCreate: (Database db, int version) async {
          return await db.execute(
              '''CREATE TABLE IF NOT EXISTS purpose_tag (id INTEGER PRIMARY KEY, purpose_name TEXT, register_at DATETIME, updated_at DATETIME)''');
        },
      );
    } on Exception catch (exception) {
      debugPrint(
          "PurposeListController PurposeListController initDatabase error");
      Exception(exception);
    }
  }

  @override
  Future<SettingModel> selectAllExecute() async {
    SettingModel model = SettingModel();
    debugPrint("selectAllExecute() start");
    try {
      // var exist = await databaseExists(_databasePath);
      //
      // if (!exist) {
      //   debugPrint("データベースが存在しません");
      //   return model;
      // }

      debugPrint("selectAllExecute() start: ");
      List<Map<String, Object?>> records = await PurposeListController._database
          .rawQuery('SELECT * FROM purpose_tag;');
      debugPrint("selectAllExecute() start: ${records}");
      List<PurposeEntity> purposeList = [];
      for (var record in records) {
        PurposeEntity purpose = PurposeEntity.fromMap(record);
        debugPrint("id: ${purpose.id} name:${purpose.purposeName}");
        purposeList.add(purpose);
      }
      model.purposeLists = purposeList;
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
    }

    return model;
  }

  @override
  Future<SettingModel> selectPurposeDataByIdExecute(int id) async {
    SettingModel model = SettingModel();
    try {
      List<Map<String, Object?>> records = await PurposeListController._database
          .rawQuery('SELECT * FROM purpose_tag WHERE id = ${id}');
      model.selectedPurposeData = PurposeEntity.fromMap(records.first);
      debugPrint(
          "update id: ${model.selectedPurposeData.id} name:${model.selectedPurposeData.purposeName}");
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
    }
    return model;
  }

  @override
  Future<void> insertPurposeDataExecute(String purposeName) async {
    try {
      debugPrint("insertPurposeDataExecute start");
      await PurposeListController._database.transaction((txn) async {
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

  @override
  Future<void> updatePurposeDataExecute(PurposeEntity entity) async {
    try {
      await PurposeListController._database.rawUpdate(
          'UPDATE purpose_tag SET purpose_name = ?, updated_at = ? WHERE id = ?',
          [entity.purposeName, DateTime.now().toString(), entity.id]);
    } on Exception catch (exception) {
      debugPrint("PurposeListController updatePurposeDataExecute error");
      Exception(exception);
    }
  }

  @override
  Future<int> deletePurposeDataExecute(int id) async {
    try {
      int deleteCount = await PurposeListController._database
          .rawDelete('DELETE FROM purpose_tag WHERE id = $id');
      return deleteCount;
    } on Exception catch (exception) {
      debugPrint("PurposeListController deletePurposeDataExecute error");
      Exception(exception);
      return 0;
    }
  }
}
