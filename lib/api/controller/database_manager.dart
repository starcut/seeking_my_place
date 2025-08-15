import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static final DatabaseManager shared = DatabaseManager._init();

  late Database _database;
  late String _databasePath;

  final dbName = "place_list.db";

  final tableNamePlaceList = "place_list";
  final columnPlaceListId = "id";
  final columnPlaceListPlaceName = "place_name";
  final columnPlaceListAddress = "address";
  final columnPlaceListLatitude = "latitude";
  final columnPlaceListLongitude = "longitude";
  final columnPlaceListUrl = "url";
  final columnPlaceListPurpose = "purpose";
  final columnPlaceListCategory = "category";
  final columnPlaceListIsVisited = "is_visited";
  final columnPlaceListRegisterAt = "register_at";
  final columnPlaceListUpdateAt = "update_at";

  final masterTableNamePurpose = "master_table_purpose";
  final columnMasterPurposeId = "id";
  final columnMasterPurposeText = "purpose_text";

  factory DatabaseManager() {
    return shared;
  }

  DatabaseManager._init() {
    _databasePath = "";
  }

  Future<void> initDatabase() async {
    debugPrint("initDatabaseExecute start");
    try {
      await Directory(await getDatabasesPath()).create(recursive: true);
      _databasePath = join(await getDatabasesPath(), dbName);
      debugPrint(_databasePath);
    } on Exception catch (exception) {
      debugPrint("database not exist");
      Exception(exception);
      return;
    }
    debugPrint("DBが作成されました。");

    try {
      _database = await openDatabase(
        _databasePath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              '''CREATE TABLE IF NOT EXISTS $tableNamePlaceList (
                  $columnPlaceListId INTEGER PRIMARY KEY,
                  $columnPlaceListPlaceName TEXT,
                  $columnPlaceListAddress TEXT,
                  $columnPlaceListLatitude NUMERIC,
                  $columnPlaceListLongitude NUMERIC,
                  $columnPlaceListUrl TEXT,
                  $columnPlaceListPurpose INTEGER,
                  $columnPlaceListCategory Text,
                  $columnPlaceListIsVisited INTEGER,
                  $columnPlaceListRegisterAt DATETIME,
                  $columnPlaceListUpdateAt DATETIME
              )''');

          await db.execute(
              '''CREATE TABLE IF NOT EXISTS $masterTableNamePurpose (
                  $columnMasterPurposeId INTEGER PRIMARY KEY,
                  $columnMasterPurposeText TEXT
              )''');
        },
      );

      int dataNum = await getCountPurposeMasterData();
      if(dataNum == 0) {
        await insertPurpose("未設定");
      }
    } on Exception catch (exception) {
      debugPrint("DatabaseManager initDatabase error");
      debugPrint("$exception");
      Exception(exception);
    }
  }

  Future<List<FavoritePlaceEntity>> selectAllPlaces() async {
    debugPrint("selectAllPlaces() start");
    try {
      var exist = await databaseExists(_databasePath);

      if (!exist) {
        debugPrint("データベースが存在しません");
        return <FavoritePlaceEntity>[];
      }

      debugPrint("これから$tableNamePlaceListのselect文");
      List<Map<String, Object?>> records = await _database
          .rawQuery('SELECT * FROM $tableNamePlaceList;');
      debugPrint("selectAllPlaces() start: $records"
          "");
      List<FavoritePlaceEntity> placeList = <FavoritePlaceEntity>[];
      for (var record in records) {
        debugPrint("fromData: $record");
        FavoritePlaceEntity placeData = FavoritePlaceEntity.fromData(record);
        placeList.add(placeData);
      }
      return placeList;
    } on Exception catch (exception) {
      debugPrint("DatabaseManager selectAllPlaces error");
      debugPrint("$exception");
      return <FavoritePlaceEntity>[];
    }
  }

  Future insertRegisterPlaceData(FavoritePlaceEntity favoritePlaceData) async {
    try {
      debugPrint("start: DatabaseManager insertRegisterPlaceData");
      await _database.transaction((txn) async {
        final sql = 'INSERT INTO $tableNamePlaceList '
            '($columnPlaceListPlaceName, $columnPlaceListAddress,'
            ' $columnPlaceListLatitude, $columnPlaceListLongitude,'
            ' $columnPlaceListUrl, $columnPlaceListPurpose,'
            ' $columnPlaceListCategory, $columnPlaceListIsVisited,'
            ' $columnPlaceListRegisterAt, $columnPlaceListUpdateAt) '
            'VALUES '
            '("${favoritePlaceData.placeName}", "${favoritePlaceData.address}",'
            ' ${favoritePlaceData.latitude}, ${favoritePlaceData.longitude},'
            ' "${favoritePlaceData.url}", ${favoritePlaceData.purpose},'
            ' "${favoritePlaceData.category}", ${favoritePlaceData.isVisited},'
            ' "${DateTime.now().toString()}", "${DateTime.now().toString()}")';
        print(sql);
        await txn.rawInsert(sql);
      });
      debugPrint("end: DatabaseManager insertRegisterPlaceData");
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager insertRegisterPlaceData");
      debugPrint("$exception");
      Exception(exception);
    }
  }


  Future<List<PurposeEntity>> selectAllPurposeMasterData() async {
    debugPrint("start: selectAllPurposeMasterData()");
    try {
      var exist = await databaseExists(_databasePath);

      if (!exist) {
        debugPrint("Not Found Database");
        return <PurposeEntity>[];
      }

      List<Map<String, Object?>> records = await _database
          .rawQuery('SELECT * FROM $masterTableNamePurpose;');
      List<PurposeEntity> imageDataList = <PurposeEntity>[];
      for (var record in records) {
        debugPrint("fromData: $record");
        PurposeEntity imageDataEntity = PurposeEntity.fromData(record);
        imageDataList.add(imageDataEntity);
      }
      print(imageDataList);
      return imageDataList;
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager selectAllPurposeMasterData");
      debugPrint("$exception");
      return <PurposeEntity>[];
    }
  }

  Future<int> getCountPurposeMasterData() async {
    debugPrint("start: getCountPurposeMasterData()");
    try {
      var exist = await databaseExists(_databasePath);

      if (!exist) {
        debugPrint("Not Found Database");
        return 0;
      }

      final countData = await _database
          .rawQuery('SELECT COUNT(*) FROM $masterTableNamePurpose;');
      print(Sqflite.firstIntValue(countData) ?? 0);
      return Sqflite.firstIntValue(countData) ?? 0;
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager getCountPurposeMasterData");
      debugPrint("$exception");
      return 0;
    }
  }

  Future insertPurpose(String purposeText) async {
    try {
      debugPrint("start: DatabaseManager insertImage");
      await _database.transaction((txn) async {
        await txn.rawInsert('INSERT INTO $masterTableNamePurpose '
            '($columnMasterPurposeText) '
            'VALUES '
            '("$purposeText")');
      });
      debugPrint("register complete：${columnMasterPurposeText}");
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager insertPurpose");
      debugPrint("$exception");
      Exception(exception);
    }
  }
}