import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/place_local_data_source.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';

abstract class ImportLocalDataSource {
  /// .json ファイルを選択し、place_list・relation_place_purpose の内容を
  /// アプリのデータベースへ取り込む。place_name・address・url が完全一致する
  /// 既存 Place がある場合は新規登録せず、purposes のみ既存 Place に反映する。
  Future<ImportResult> importJsonFile();
}

class ImportLocalDataSourceImpl implements ImportLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ImportLocalDataSourceImpl(this._databaseHelper);

  late final PlaceLocalDataSource _placeDataSource = PlaceLocalDataSourceImpl(
    _databaseHelper,
  );

  @override
  Future<ImportResult> importJsonFile() async {
    final places = await _pickAndParseJsonPlaces();
    final resolvedPlaces = await _resolvePlaceIds(places);
    await _registerJsonPlaces(resolvedPlaces);
    return ImportResult.success;
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

  /// .json ファイルを選択し、トップレベルの "places" を取得する。
  /// Place の DB 登録・Purpose の解決・重複判定はまだ行わない。
  Future<List<dynamic>> _pickAndParseJsonPlaces() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final pickedPath = result?.files.single.path;
    if (pickedPath == null) {
      throw Exception('ファイルが選択されませんでした。');
    }

    final content = await File(pickedPath).readAsString();

    Object? decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw Exception('JSON の解析に失敗しました。');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('JSON のトップレベルがオブジェクトではありません。');
    }

    final places = decoded['places'];
    if (places is! List) {
      throw Exception('places が存在しない、または配列ではありません。');
    }

    return places;
  }

  /// [places]（[_pickAndParseJsonPlaces] の戻り値）の各 Place について、
  /// place_name・address・url が完全一致する既存 Place を検索し、
  /// 存在する場合はその place_id を、存在しない場合は新規発行した
  /// place_id を割り当てる。place_list・relation_place_purpose への
  /// 登録はまだ行わない。
  Future<List<({Map<String, dynamic> json, String placeId, bool isExisting})>>
  _resolvePlaceIds(List<dynamic> places) async {
    final existingRows = await _placeDataSource.getAllPlaces();

    // place_name・address・url の組をキーとする。3 項目すべてが完全一致する
    // 場合のみ同一 Place とみなすため、レコード（タプル）をそのまま Map の
    // キーに使い、文字列連結による区切り文字の衝突を避ける。
    final placeIdByKey = <(Object?, Object?, Object?), String>{};
    final usedPlaceIds = <String>{};
    for (final row in existingRows) {
      final placeId = row[DatabaseHelper.colPlaceId] as String;
      usedPlaceIds.add(placeId);
      placeIdByKey[(
        row[DatabaseHelper.colPlaceName],
        row[DatabaseHelper.colAddress],
        row[DatabaseHelper.colUrl],
      )] = placeId;
    }

    final resolved =
        <({Map<String, dynamic> json, String placeId, bool isExisting})>[];
    for (final place in places) {
      final json = place as Map<String, dynamic>;
      final key = (
        json[DatabaseHelper.colPlaceName],
        json[DatabaseHelper.colAddress],
        json[DatabaseHelper.colUrl],
      );

      final existingPlaceId = placeIdByKey[key];
      if (existingPlaceId != null) {
        resolved.add((json: json, placeId: existingPlaceId, isExisting: true));
        continue;
      }

      final newPlaceId = _generateUniquePlaceId(usedPlaceIds);
      placeIdByKey[key] = newPlaceId;
      resolved.add((json: json, placeId: newPlaceId, isExisting: false));
    }

    return resolved;
  }

  /// [_resolvePlaceIds] の結果を基に、新規 Place の place_list への登録と
  /// purposes の relation_place_purpose への反映を行う。
  ///
  /// - 新規 Place: [PlaceLocalDataSourceImpl.savePlace] で登録した上で、
  ///   [PlaceLocalDataSourceImpl.savePlacePurposes] で purposes を登録する。
  /// - 既存 Place: place_list への登録は行わず、既存の purpose_id と
  ///   JSON の purposes を統合した上で [savePlacePurposes] を呼び直すことで、
  ///   未登録分だけを追加する（savePlacePurposes は一旦削除して入れ直すため、
  ///   既存分も含めて渡すことで重複登録・欠落のいずれも防ぐ）。
  ///
  /// purpose_id が master_table_purpose に存在しない場合は、1 件でも
  /// 書き込みを行う前に例外を投げる。
  Future<void> _registerJsonPlaces(
    List<({Map<String, dynamic> json, String placeId, bool isExisting})>
    resolvedPlaces,
  ) async {
    final validPurposeIds = (await _placeDataSource.getAllPurposes())
        .map((row) => row[DatabaseHelper.colPurposeId] as String)
        .toSet();

    for (final resolved in resolvedPlaces) {
      for (final purposeId in _extractPurposeIds(resolved.json)) {
        if (!validPurposeIds.contains(purposeId)) {
          throw Exception(
            'purpose_id が master_table_purpose に存在しません: $purposeId',
          );
        }
      }
    }

    for (final resolved in resolvedPlaces) {
      final purposeIds = _extractPurposeIds(resolved.json);

      if (!resolved.isExisting) {
        await _placeDataSource.savePlace(
          _toPlaceRow(resolved.json, resolved.placeId),
        );
        await _placeDataSource.savePlacePurposes(resolved.placeId, purposeIds);
        continue;
      }

      final existingPurposeIds = await _placeDataSource.getPurposeIdsForPlace(
        resolved.placeId,
      );
      final mergedPurposeIds = {...existingPurposeIds, ...purposeIds}.toList();
      await _placeDataSource.savePlacePurposes(
        resolved.placeId,
        mergedPurposeIds,
      );
    }
  }

  /// JSON の Place（[json]）から place_list 登録用の行データを組み立てる。
  /// is_visited は JSON の bool を DB の 0/1 に変換する。
  Map<String, dynamic> _toPlaceRow(Map<String, dynamic> json, String placeId) {
    return {
      DatabaseHelper.colPlaceId: placeId,
      DatabaseHelper.colPlaceName: json[DatabaseHelper.colPlaceName],
      DatabaseHelper.colAddress: json[DatabaseHelper.colAddress],
      DatabaseHelper.colLatitude: (json[DatabaseHelper.colLatitude] as num)
          .toDouble(),
      DatabaseHelper.colLongitude: (json[DatabaseHelper.colLongitude] as num)
          .toDouble(),
      DatabaseHelper.colUrl: json[DatabaseHelper.colUrl],
      DatabaseHelper.colCategory: json[DatabaseHelper.colCategory],
      DatabaseHelper.colIsVisited:
          (json[DatabaseHelper.colIsVisited] as bool) ? 1 : 0,
      DatabaseHelper.colCreatedAt: json[DatabaseHelper.colCreatedAt],
      DatabaseHelper.colUpdatedAt: json[DatabaseHelper.colUpdatedAt],
    };
  }

  /// JSON の Place から purposes（purpose_id のリスト）を取り出す。
  /// 存在しない場合は空リストとして扱う。
  List<String> _extractPurposeIds(Map<String, dynamic> json) {
    final purposes = json['purposes'];
    if (purposes == null) return [];
    return (purposes as List).cast<String>();
  }
}
