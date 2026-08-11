import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';
import 'package:sqflite/sqflite.dart';

abstract class ImportLocalDataSource {
  /// .db または .csv ファイルを選択し、place_list の内容をアプリの
  /// データベースへ取り込む。PlaceId は既存データと重複しないよう、
  /// 取り込み時に新しい値を発行する。
  Future<ImportResult> importDatabaseFile();
}

class ImportLocalDataSourceImpl implements ImportLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ImportLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<ImportResult> importDatabaseFile() async {
    // iOS の「ファイル」App では .db のような未登録の拡張子を allowedExtensions
    // で指定するとファイルがグレーアウトして選択できないため、
    // ここでは絞り込みをかけず全ファイルから選択可能にする。
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final pickedPath = result?.files.single.path;
    if (pickedPath == null) {
      return ImportResult.cancelled;
    }

    final rows = pickedPath.toLowerCase().endsWith('.csv')
        ? await _readCsvRows(pickedPath)
        : await _readDbRows(pickedPath);

    await _insertPlaces(rows);
    return ImportResult.success;
  }

  Future<List<Map<String, Object?>>> _readDbRows(String path) async {
    final importDb = await openDatabase(path, readOnly: true);
    try {
      return await importDb.query(DatabaseHelper.tablePlace);
    } finally {
      await importDb.close();
    }
  }

  /// export_csv が書き出すテンプレート（1行目がヘッダー、
  /// [DatabaseHelper] の place_list 列名と一致）のみを対象とする。
  Future<List<Map<String, Object?>>> _readCsvRows(String path) async {
    final content = await File(path).readAsString();
    final table = const CsvToListConverter().convert(content);
    if (table.isEmpty) return [];

    final header = table.first.map((column) => column.toString()).toList();
    return table
        .skip(1)
        .where((row) => row.length == header.length)
        .map((row) => Map<String, Object?>.fromIterables(header, row))
        .toList();
  }

  Future<void> _insertPlaces(List<Map<String, Object?>> rows) async {
    final db = _databaseHelper.database;
    final existingIds = await db.query(
      DatabaseHelper.tablePlace,
      columns: [DatabaseHelper.colPlaceId],
    );
    final usedPlaceIds = existingIds
        .map((row) => row[DatabaseHelper.colPlaceId] as String)
        .toSet();

    await db.transaction((txn) async {
      for (final row in rows) {
        final newRow = Map<String, Object?>.from(row)
          ..[DatabaseHelper.colPlaceId] = _generateUniquePlaceId(usedPlaceIds)
          ..[DatabaseHelper.colLatitude] =
              (row[DatabaseHelper.colLatitude] as num).toDouble()
          ..[DatabaseHelper.colLongitude] =
              (row[DatabaseHelper.colLongitude] as num).toDouble()
          ..[DatabaseHelper.colIsVisited] =
              (row[DatabaseHelper.colIsVisited] as num).toInt();
        await txn.insert(DatabaseHelper.tablePlace, newRow);
      }
    });
  }

  /// 既存データ・今回のインポート内で発行済みの ID と重複しない
  /// PlaceId を新規発行する。
  String _generateUniquePlaceId(Set<String> usedPlaceIds) {
    var candidate = DateTime.now().microsecondsSinceEpoch;
    while (usedPlaceIds.contains(candidate.toString())) {
      candidate++;
    }
    final newPlaceId = candidate.toString();
    usedPlaceIds.add(newPlaceId);
    return newPlaceId;
  }
}
