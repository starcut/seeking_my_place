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
    return rows.map((row) => PlaceDto.fromRow(row).toEntity()).toList();
  }

  @override
  Future<Place> getById(String placeId) async {
    final row = await _dataSource.getPlace(placeId);
    if (row == null) {
      throw Exception('Place not found: $placeId');
    }
    return PlaceDto.fromRow(row).toEntity();
  }

  @override
  Future<void> create(Place place) async {
    await _dataSource.savePlace(place.toDto().toRow());
  }

  @override
  Future<void> update(Place place) async {
    await _dataSource.savePlace(place.toDto().toRow());
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
