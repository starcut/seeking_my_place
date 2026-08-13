import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/place_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/dto/place_dto.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

abstract class ExportLocalDataSource {
  /// place_list の内容を、紐づく purpose 名（relation_place_purpose 経由で
  /// master_table_purpose から解決）を含めた .txt ファイルとして書き出す。
  /// iOS では共有シート、Android では端末のストレージへの保存ダイアログ経由となる。
  Future<ShareResultStatus> exportTxtFile();

  /// place_list の全カラムと、紐づく purpose_id（relation_place_purpose 経由）
  /// を含めた .json ファイルとして書き出す。
  /// iOS では共有シート、Android では端末のストレージへの保存ダイアログ経由となる。
  Future<ShareResultStatus> exportJsonFile();
}

class ExportLocalDataSourceImpl implements ExportLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ExportLocalDataSourceImpl(this._databaseHelper);

  late final PlaceLocalDataSource _placeDataSource = PlaceLocalDataSourceImpl(
    _databaseHelper,
  );

  @override
  Future<ShareResultStatus> exportTxtFile() async {
    return _deliver(await _prepareTxtFile());
  }

  @override
  Future<ShareResultStatus> exportJsonFile() async {
    return _deliver(await _prepareJsonFile());
  }

  /// [file] を書き出す。iOS では共有シート、Android では OS 標準の保存先選択
  /// ダイアログ（Storage Access Framework）経由で端末のストレージへ保存する。
  ///
  /// Android の共有シートには iOS の「ファイル」に相当する、保存先を問わず
  /// 確実に使えるローカル保存の選択肢がないため、Android のみ保存ダイアログを
  /// 直接呼び出す。
  Future<ShareResultStatus> _deliver(XFile file) async {
    if (Platform.isAndroid) {
      final bytes = await file.readAsBytes();
      final savedPath = await FilePicker.platform.saveFile(
        fileName: basename(file.path),
        bytes: bytes,
      );
      return savedPath != null
          ? ShareResultStatus.success
          : ShareResultStatus.dismissed;
    }

    final result = await SharePlus.instance.share(
      ShareParams(files: [file]),
    );
    return result.status;
  }

  Future<XFile> _prepareTxtFile() async {
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
    return _writeTxt(
      directory: tempDir,
      fileName: DatabaseHelper.tablePlace,
      places: places,
      purposeNamesByPlaceId: purposeNamesByPlaceId,
    );
  }

  /// place_list の全カラムに、relation_place_purpose から取得した purpose_id
  /// 一覧を "purposes" として追加した JSON データを一時領域に作成する。
  /// master_table_purpose の内容は含めない。
  Future<XFile> _prepareJsonFile() async {
    final rows = await _placeDataSource.getAllPlaces();

    final places = <Map<String, Object?>>[];
    for (final row in rows) {
      final dto = PlaceDto.fromRow(row);
      final purposeIds = await _placeDataSource.getPurposeIdsForPlace(
        dto.placeId,
      );
      places.add({
        ...dto.toRow(),
        DatabaseHelper.colIsVisited: dto.isVisited == 1,
        'purposes': purposeIds,
      });
    }

    final tempDir = await getTemporaryDirectory();
    return _writeJson(
      directory: tempDir,
      fileName: DatabaseHelper.tablePlace,
      data: {'places': places},
    );
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

  Future<XFile> _writeJson({
    required Directory directory,
    required String fileName,
    required Map<String, Object?> data,
  }) async {
    const encoder = JsonEncoder.withIndent('  ');
    final jsonContent = encoder.convert(data);

    final file = File(join(directory.path, '$fileName.json'));
    await file.writeAsString(jsonContent);
    return XFile(file.path);
  }
}
