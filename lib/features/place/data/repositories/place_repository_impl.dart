import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/place_local_data_source.dart';
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
    return rows.map(_rowToPlace).toList();
  }

  @override
  Future<Place> getById(String placeId) async {
    final row = await _dataSource.getPlace(placeId);
    if (row == null) {
      throw Exception('Place not found: $placeId');
    }
    return _rowToPlace(row);
  }

  @override
  Future<void> create(Place place) async {
    await _dataSource.savePlace(_placeToRow(place));
  }

  @override
  Future<void> update(Place place) async {
    await _dataSource.savePlace(_placeToRow(place));
  }

  @override
  Future<void> delete(String placeId) async {
    await _dataSource.deletePlace(placeId);
  }

  // ---------- Purpose ----------

  @override
  Future<List<Purpose>> getAllPurposes() async {
    final rows = await _dataSource.getAllPurposes();
    return rows.map(_rowToPurpose).toList();
  }

  // ---------- Mapping helpers ----------

  Place _rowToPlace(Map<String, dynamic> row) {
    return Place(
      placeId: row[DatabaseHelper.colPlaceId] as String,
      placeName: row[DatabaseHelper.colPlaceName] as String,
      address: row[DatabaseHelper.colAddress] as String,
      latitude: (row[DatabaseHelper.colLatitude] as num).toDouble(),
      longitude: (row[DatabaseHelper.colLongitude] as num).toDouble(),
      url: row[DatabaseHelper.colUrl] as String,
      category: row[DatabaseHelper.colCategory] as String,
      isVisited: (row[DatabaseHelper.colIsVisited] as int) == 1,
      createdAt: DateTime.parse(row[DatabaseHelper.colCreatedAt] as String),
      updatedAt: DateTime.parse(row[DatabaseHelper.colUpdatedAt] as String),
    );
  }

  Map<String, dynamic> _placeToRow(Place place) {
    return {
      DatabaseHelper.colPlaceId: place.placeId,
      DatabaseHelper.colPlaceName: place.placeName,
      DatabaseHelper.colAddress: place.address,
      DatabaseHelper.colLatitude: place.latitude,
      DatabaseHelper.colLongitude: place.longitude,
      DatabaseHelper.colUrl: place.url,
      DatabaseHelper.colCategory: place.category,
      DatabaseHelper.colIsVisited: place.isVisited ? 1 : 0,
      DatabaseHelper.colCreatedAt: place.createdAt.toIso8601String(),
      DatabaseHelper.colUpdatedAt: place.updatedAt.toIso8601String(),
    };
  }

  Purpose _rowToPurpose(Map<String, dynamic> row) {
    return Purpose(
      purposeId: row[DatabaseHelper.colPurposeId] as String,
      purposeName: row[DatabaseHelper.colPurposeName] as String,
    );
  }
}
