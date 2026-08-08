import 'package:seeking_my_place/features/place/data/datasources/local/place_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/dto/place_dto.dart';
import 'package:seeking_my_place/features/place/data/dto/purpose_dto.dart';
import 'package:seeking_my_place/features/place/data/mappers/place_mapper.dart';
import 'package:seeking_my_place/features/place/data/mappers/purpose_mapper.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/entities/purpose.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceLocalDataSource _dataSource;

  PlaceRepositoryImpl(this._dataSource);

  // ---------- Place ----------

  @override
  Future<List<Place>> getAll() async {
    final rows = await _dataSource.getAllPlaces();
    final places = <Place>[];
    for (final row in rows) {
      final dto = PlaceDto.fromRow(row);
      final purposes = await _resolvePurposes(dto.placeId);
      places.add(dto.toEntity().copyWith(purposes: purposes));
    }
    return places;
  }

  @override
  Future<Place> getById(String placeId) async {
    final row = await _dataSource.getPlace(placeId);
    if (row == null) {
      throw Exception('Place not found: $placeId');
    }
    final purposes = await _resolvePurposes(placeId);
    return PlaceDto.fromRow(row).toEntity().copyWith(purposes: purposes);
  }

  @override
  Future<void> create(Place place) async {
    await _dataSource.savePlace(place.toDto().toRow());
    await _dataSource.savePlacePurposes(
      place.placeId,
      place.purposes.map((purpose) => purpose.purposeId).toList(),
    );
  }

  @override
  Future<void> update(Place place) async {
    await _dataSource.savePlace(place.toDto().toRow());
    await _dataSource.savePlacePurposes(
      place.placeId,
      place.purposes.map((purpose) => purpose.purposeId).toList(),
    );
  }

  /// [placeId] に紐づく purpose_id を relation_place_purpose から取得し、
  /// master_table_purpose の内容（getAllPurposes）と突き合わせて解決する。
  Future<List<Purpose>> _resolvePurposes(String placeId) async {
    final purposeIds = await _dataSource.getPurposeIdsForPlace(placeId);
    if (purposeIds.isEmpty) return [];
    final idSet = purposeIds.toSet();
    final allPurposes = await getAllPurposes();
    return allPurposes.where((p) => idSet.contains(p.purposeId)).toList();
  }

  @override
  Future<void> delete(String placeId) async {
    await _dataSource.deletePlace(placeId);
  }

  // ---------- Purpose ----------

  @override
  Future<List<Purpose>> getAllPurposes() async {
    final rows = await _dataSource.getAllPurposes();
    return rows.map((row) => PurposeDto.fromRow(row).toEntity()).toList();
  }
}
