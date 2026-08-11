import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class PlaceLocalDataSource {
  Future<void> savePlace(Map<String, dynamic> place);
  Future<Map<String, dynamic>?> getPlace(String id);
  Future<List<Map<String, dynamic>>> getAllPlaces();
  Future<void> deletePlace(String id);
  Future<List<Map<String, dynamic>>> getAllPurposes();
  Future<List<String>> getPurposeIdsForPlace(String placeId);
  Future<void> savePlacePurposes(String placeId, List<String> purposeIds);
}

class PlaceLocalDataSourceImpl implements PlaceLocalDataSource {
  final DatabaseHelper _databaseHelper;

  PlaceLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<void> savePlace(Map<String, dynamic> place) async {
    final db = _databaseHelper.database;
    await db.insert(
      DatabaseHelper.tablePlace,
      place,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>?> getPlace(String id) async {
    final db = _databaseHelper.database;
    final rows = await db.query(
      DatabaseHelper.tablePlace,
      where: '${DatabaseHelper.colPlaceId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPlaces() async {
    final db = _databaseHelper.database;
    return db.query(DatabaseHelper.tablePlace);
  }

  @override
  Future<void> deletePlace(String id) async {
    final db = _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tablePlace,
      where: '${DatabaseHelper.colPlaceId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPurposes() async {
    final db = _databaseHelper.database;
    return db.query(
      DatabaseHelper.tablePurpose,
      orderBy: DatabaseHelper.colPurposeId,
    );
  }

  @override
  Future<List<String>> getPurposeIdsForPlace(String placeId) async {
    final db = _databaseHelper.database;
    final rows = await db.query(
      DatabaseHelper.tableRelationPlacePurpose,
      columns: [DatabaseHelper.colPurposeId],
      where: '${DatabaseHelper.colPlaceId} = ?',
      whereArgs: [placeId],
    );
    return rows.map((row) => row[DatabaseHelper.colPurposeId] as String).toList();
  }

  @override
  Future<void> savePlacePurposes(String placeId, List<String> purposeIds) async {
    final db = _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseHelper.tableRelationPlacePurpose,
        where: '${DatabaseHelper.colPlaceId} = ?',
        whereArgs: [placeId],
      );
      for (final purposeId in purposeIds) {
        await txn.insert(DatabaseHelper.tableRelationPlacePurpose, {
          DatabaseHelper.colPlaceId: placeId,
          DatabaseHelper.colPurposeId: purposeId,
        });
      }
    });
  }
}
