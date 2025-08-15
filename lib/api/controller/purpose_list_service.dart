import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:sqflite/sqflite.dart';

final purposeListControllerProvider =
    Provider<PurposeListService>((ref) => PurposeListService());

class PurposeListService {
  static late Database _database;
  static late String _databasePath;

  Future<void> initDatabaseExecute() async {
    try {
      var databasePath = await getDatabasesPath();
      await Directory(databasePath).create(recursive: true);
    } on Exception catch (exception) {
      debugPrint("database not exist");
      Exception(exception);
    }

    try {
      PurposeListService._database = await openDatabase(
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

  Future<List<PurposeEntity>> selectAllExecute() async {
    debugPrint("selectAllExecute() start");
    List<PurposeEntity> purposeList = [];
    try {
      // var exist = await databaseExists(_databasePath);
      //
      // if (!exist) {
      //   debugPrint("データベースが存在しません");
      //   return model;
      // }

      debugPrint("selectAllExecute() start: ");
      List<Map<String, Object?>> records = await PurposeListService._database
          .rawQuery('SELECT * FROM purpose_tag;');
      debugPrint("selectAllExecute() start: ${records}");

      for (var record in records) {
        PurposeEntity purpose = PurposeEntity.fromMap(record);
        debugPrint("id: ${purpose.id} name:${purpose.purposeText}");
        purposeList.add(purpose);
      }
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
          "update id: ${selectedPurposeData.id} name:${selectedPurposeData.purposeText}");
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
          [entity.purposeText, DateTime.now().toString(), entity.id]);
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
