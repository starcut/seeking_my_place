import 'package:flutter/cupertino.dart';
import 'package:seeking_my_place/model/setting_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:seeking_my_place/api/controller/purpose_list_controller_impl.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'dart:io';

class PurposeListController implements PurposeListControllerImpl {
  late Database _database;
  late String databasePath;
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
      _database = await openDatabase(
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

    try {
      _database = await openDatabase(
        'seeking_place.db',
        version: 1,
        onCreate: (Database db, int version) async {
          return await db.execute(
              '''CREATE TABLE IF NOT EXISTS purpose_tag (id INTEGER PRIMARY KEY, purpose_name TEXT, register_at DATETIME, updated_at DATETIME)''');
        },
      );
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
    }

    try {
      // var exist = await databaseExists(databasePath);
      // if (!exist) {
      //   print("データベースが存在しません");
      //   return model;
      // }

      List<Map<String, Object?>> records =
          await _database.rawQuery('SELECT * FROM purpose_tag;');
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
  Future<void> insertPurposeDataExecute(String purposeName) async {
    try {
      debugPrint("insertPurposeDataExecute start");
      await _database.transaction((txn) async {
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
  Future<int> deletePurposeDataExecute(int id) async {
    try {
      int deleteCount =
          await _database.rawDelete('DELETE FROM purpose_tag WHERE id = $id');
      return deleteCount;
    } on Exception catch (exception) {
      debugPrint("PurposeListController initDatabase error");
      Exception(exception);
      return 0;
    }
  }
}
