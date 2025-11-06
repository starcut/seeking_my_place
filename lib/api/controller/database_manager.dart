import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/cupertino.dart';

import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

class DatabaseManager {
  static final DatabaseManager shared = DatabaseManager._init();

  late Database _database;
  Database get database => _database;

  late String _databasePath;
  String get databasePath => _databasePath;

  final _dbName = "place_list.db";

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
  final columnMasterPurposeName = "purpose_name";

  factory DatabaseManager() {
    return shared;
  }

  DatabaseManager._init() {
    _databasePath = "";
  }

  Future<void> initDatabase() async {
    try {
      await Directory(await getDatabasesPath()).create(recursive: true);
      _databasePath = join(await getDatabasesPath(), _dbName);
      debugPrint(_databasePath);
    } on Exception catch (exception) {
      debugPrint("database not exist");
      Exception(exception);
      return;
    }

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
                  $columnPlaceListPurpose TEXT,
                  $columnPlaceListCategory Text,
                  $columnPlaceListIsVisited INTEGER,
                  $columnPlaceListRegisterAt DATETIME,
                  $columnPlaceListUpdateAt DATETIME
              )''');

          await db.execute(
              '''CREATE TABLE IF NOT EXISTS $masterTableNamePurpose (
                  $columnMasterPurposeId INTEGER PRIMARY KEY,
                  $columnMasterPurposeName TEXT
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
    try {
      var exist = await databaseExists(_databasePath);
      if (!exist) {
        debugPrint("データベースが存在しません");
        return <FavoritePlaceEntity>[];
      }

      List<Map<String, Object?>> records = await _database
          .rawQuery('SELECT * FROM $tableNamePlaceList;');
      List<FavoritePlaceEntity> placeList = <FavoritePlaceEntity>[];
      for (var record in records) {
        FavoritePlaceEntity placeData = FavoritePlaceEntity.fromData(record);
        placeList.add(placeData);
      }
      return placeList;
    } on Exception catch (exception) {
      debugPrint("DatabaseManager selectAllPlaces $exception");
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
            ' "${favoritePlaceData.url}", "${favoritePlaceData.purpose}",'
            ' "${favoritePlaceData.category}", ${favoritePlaceData.isVisited},'
            ' "${DateTime.now().toString()}", "${DateTime.now().toString()}")';
        print(sql);
        await txn.rawInsert(sql);
      });
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager insertRegisterPlaceData $exception");
      Exception(exception);
    }
  }

  Future deleterFavoritePlace(int id) async {
    try {
      debugPrint("start: DatabaseManager deleterFavoritePlace");
      await _database.transaction((txn) async {
        final sql = 'DELETE FROM  $tableNamePlaceList '
            'WHERE $columnPlaceListId = $id';
        print(sql);
        await txn.rawInsert(sql);
      });
    } on Exception catch (exception) {
      debugPrint("DatabaseManager deleterFavoritePlace $exception");
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
      List<PurposeEntity> purposeList = <PurposeEntity>[];
      for (var record in records) {
        PurposeEntity purposeEntity = PurposeEntity.fromData(record);
        purposeList.add(purposeEntity);
      }
      print(purposeList);
      return purposeList;
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager selectAllPurposeMasterData $exception");
      return <PurposeEntity>[];
    }
  }

  Future<PurposeEntity?> getPurposeMasterData(int purposeId) async {
    debugPrint("start: selectAllPurposeMasterData()");
    try {
      var exist = await databaseExists(_databasePath);
      if (!exist) {
        debugPrint("Not Found Database");
        return null;
      }

      List<Map<String, Object?>> records = await _database
          .rawQuery('SELECT * FROM $masterTableNamePurpose WHERE $columnMasterPurposeId = $purposeId;');
      final record = records.first;
      final purpose = PurposeEntity.fromData(record);
      return purpose;
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager selectAllPurposeMasterData $exception");
      return null;
    }
  }

  Future<int> getCountPurposeMasterData() async {
    try {
      var exist = await databaseExists(_databasePath);

      if (!exist) {
        debugPrint("Not Found Database");
        return 0;
      }

      final countData = await _database.rawQuery('SELECT COUNT(*) FROM $masterTableNamePurpose;');
      print(Sqflite.firstIntValue(countData) ?? 0);
      return Sqflite.firstIntValue(countData) ?? 0;
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager getCountPurposeMasterData $exception");
      return 0;
    }
  }

  Future insertPurpose(String purposeText) async {
    try {
      debugPrint("start: DatabaseManager insertImage");
      await _database.transaction((txn) async {
        await txn.rawInsert('INSERT INTO $masterTableNamePurpose '
            '($columnMasterPurposeName) '
            'VALUES '
            '("$purposeText")');
      });
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager insertPurpose $exception");
      Exception(exception);
    }
  }

  Future<void> updatePurposeMasterData(PurposeEntity updatePurpose) async {
    debugPrint("start: updatePurposeMasterData()");
    try {
      var exist = await databaseExists(_databasePath);
      if (!exist) {
        debugPrint("Not Found Database");
        return;
      }

      await _database.update(
          masterTableNamePurpose,
          {columnMasterPurposeName: updatePurpose.purposeName},
          where: '$columnMasterPurposeId = ?',
          whereArgs: ['${updatePurpose.id}']
      );
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager selectAllPurposeMasterData $exception");
      return;
    }
  }

  Future<void> deletePurposeMasterData(int deletePurposeId) async {
    debugPrint("start: deletePurposeMasterData()");
    try {
      var exist = await databaseExists(_databasePath);
      if (!exist) {
        debugPrint("Not Found Database");
        return;
      }

      await _database.delete(
          masterTableNamePurpose,
          where: '$columnMasterPurposeId = ?',
          whereArgs: [deletePurposeId]
      );
    } on Exception catch (exception) {
      debugPrint("error: DatabaseManager selectAllPurposeMasterData $exception");
      return;
    }
  }

  Future importDatabaseFromCsv(File file) async {
    try {
      final content = await file.readAsString();
      var lines = content.split('\n');
      lines.removeAt(0);
      for (var line in lines) {
        final data = line.split(',');
        print("data: $data");
        final id = int.parse(data[0]);
        print("id: ${data[0]}");
        final placeName = data[1].replaceAll('"', '');
        print("placeName: ${data[1]}");
        final address = data[2].replaceAll('"', '');
        print("address: ${data[2]}");
        final latitude = double.parse(data[3]);
        print("latitude: ${data[3]}");
        final longitude = double.parse(data[4]);
        print("longitude: ${data[4]}");
        final url = data[5].replaceAll('"', '');
        print("url: ${data[5]}");
        final category = data[6].replaceAll('"', '');
        print("category: ${data[6]}");
        final purpose = data[7].replaceAll('"', '');
        print("purpose: ${data[7]}");
        final isVisited = (data[8].replaceAll('"', '') == "true");
        print("isVisited: ${data[8].replaceAll('"', '')}");

        final favoritePlaceData = FavoritePlaceEntity(
            placeName: placeName,
            address: address,
            latitude: latitude,
            longitude: longitude,
            url: url,
            category: category,
            purpose: purpose,
            isVisited: isVisited,
            registerAt: DateTime.now(),
            updateAt: DateTime.now());

        await DatabaseManager.shared.insertRegisterPlaceData(favoritePlaceData);
      }
    } catch (e) {
      print("database import error: $e");
      rethrow;
    }
  }
}