import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

abstract class ExportLocalDataSource {
  /// place_list のみを含む .db ファイルを共有シート経由で書き出す。
  Future<ShareResultStatus> exportDatabaseFile();

  /// place_list を .csv ファイルとして共有シート経由で書き出す。
  Future<ShareResultStatus> exportCsvFiles();

  /// place_list の内容を、紐づく purpose 名（relation_place_purpose 経由で
  /// master_table_purpose から解決）を含めた .txt ファイルとして
  /// 共有シート経由で書き出す。
  Future<ShareResultStatus> exportTxtFile();
}

class ExportLocalDataSourceImpl implements ExportLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ExportLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<ShareResultStatus> exportDatabaseFile() async {
    final db = _databaseHelper.database;
    // WAL モードで未反映のまま残っている変更があれば本体ファイルへ反映する。
    await db.rawQuery('PRAGMA wal_checkpoint(FULL)');

    final tempDir = await getTemporaryDirectory();
    final exportPath = join(tempDir.path, '${DatabaseHelper.tablePlace}.db');
    final exportFile = File(exportPath);
    if (await exportFile.exists()) {
      await exportFile.delete();
    }
    await File(db.path).copy(exportPath);

    // コピー先ファイルから place_list 以外のテーブルを取り除く。
    // 元の DB ファイルには一切手を加えない。
    final exportDb = await openDatabase(exportPath);
    await exportDb.execute(
      'DROP TABLE ${DatabaseHelper.tableRelationPlacePurpose}',
    );
    await exportDb.execute('DROP TABLE ${DatabaseHelper.tablePurpose}');
    await exportDb.execute('VACUUM');
    await exportDb.close();

    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(exportPath)]),
    );
    return result.status;
  }

  @override
  Future<ShareResultStatus> exportCsvFiles() async {
    final db = _databaseHelper.database;
    await db.rawQuery('PRAGMA wal_checkpoint(FULL)');

    const columns = [
      DatabaseHelper.colPlaceId,
      DatabaseHelper.colPlaceName,
      DatabaseHelper.colAddress,
      DatabaseHelper.colLatitude,
      DatabaseHelper.colLongitude,
      DatabaseHelper.colUrl,
      DatabaseHelper.colCategory,
      DatabaseHelper.colIsVisited,
      DatabaseHelper.colCreatedAt,
      DatabaseHelper.colUpdatedAt,
    ];

    final tempDir = await getTemporaryDirectory();
    final file = await _writeCsv(
      directory: tempDir,
      fileName: DatabaseHelper.tablePlace,
      columns: columns,
      rows: await db.query(DatabaseHelper.tablePlace, columns: columns),
    );

    final result = await SharePlus.instance.share(
      ShareParams(files: [file]),
    );
    return result.status;
  }

  @override
  Future<ShareResultStatus> exportTxtFile() async {
    final db = _databaseHelper.database;
    await db.rawQuery('PRAGMA wal_checkpoint(FULL)');

    const columns = [
      DatabaseHelper.colPlaceId,
      DatabaseHelper.colPlaceName,
      DatabaseHelper.colAddress,
      DatabaseHelper.colUrl,
      DatabaseHelper.colCategory,
    ];

    final places = await db.query(DatabaseHelper.tablePlace, columns: columns);
    final purposeNamesByPlaceId = await _queryPurposeNamesByPlaceId(db);

    final tempDir = await getTemporaryDirectory();
    final file = await _writeTxt(
      directory: tempDir,
      fileName: DatabaseHelper.tablePlace,
      places: places,
      purposeNamesByPlaceId: purposeNamesByPlaceId,
    );

    final result = await SharePlus.instance.share(
      ShareParams(files: [file]),
    );
    return result.status;
  }

  /// relation_place_purpose と master_table_purpose を結合し、
  /// place_id ごとの purpose_name 一覧を取得する。
  Future<Map<String, List<String>>> _queryPurposeNamesByPlaceId(
    Database db,
  ) async {
    final rows = await db.rawQuery('''
      SELECT
        r.${DatabaseHelper.colPlaceId} AS ${DatabaseHelper.colPlaceId},
        p.${DatabaseHelper.colPurposeName} AS ${DatabaseHelper.colPurposeName}
      FROM ${DatabaseHelper.tableRelationPlacePurpose} r
      JOIN ${DatabaseHelper.tablePurpose} p
        ON r.${DatabaseHelper.colPurposeId} = p.${DatabaseHelper.colPurposeId}
    ''');

    final result = <String, List<String>>{};
    for (final row in rows) {
      final placeId = row[DatabaseHelper.colPlaceId] as String;
      final purposeName = row[DatabaseHelper.colPurposeName] as String;
      result.putIfAbsent(placeId, () => []).add(purposeName);
    }
    return result;
  }

  Future<XFile> _writeTxt({
    required Directory directory,
    required String fileName,
    required List<Map<String, Object?>> places,
    required Map<String, List<String>> purposeNamesByPlaceId,
  }) async {
    const separator = '---------------------------';
    final blocks = places.map((place) {
      final placeId = place[DatabaseHelper.colPlaceId] as String;
      final purposeName = (purposeNamesByPlaceId[placeId] ?? const [])
          .join(',');

      final lines = [
        '場所\t${place[DatabaseHelper.colPlaceName]}',
        '住所\t${place[DatabaseHelper.colAddress]}',
        'URL\t${place[DatabaseHelper.colUrl]}',
        'お店のジャンル\t${place[DatabaseHelper.colCategory]}',
        '用途\t$purposeName',
      ];
      return lines.join('\n');
    });

    final txtContent = blocks.join('\n$separator\n');

    final file = File(join(directory.path, '$fileName.txt'));
    // BOM を付与し、UTF-8 であることを明示する。
    // BOM がないと Mac のエディタが「日本語（Mac OS）」と誤判定することがある。
    await file.writeAsString('﻿$txtContent');
    return XFile(file.path);
  }

  Future<XFile> _writeCsv({
    required Directory directory,
    required String fileName,
    required List<String> columns,
    required List<Map<String, Object?>> rows,
  }) async {
    final csvRows = <List<Object?>>[
      columns,
      ...rows.map((row) => columns.map((column) => row[column]).toList()),
    ];
    final csvContent = const ListToCsvConverter().convert(csvRows);

    final file = File(join(directory.path, '$fileName.csv'));
    await file.writeAsString(csvContent);
    return XFile(file.path);
  }
}
