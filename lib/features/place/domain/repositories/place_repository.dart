import '../entities/place.dart';
import '../entities/purpose.dart';

abstract class PlaceRepository {
  Future<List<Place>> getAll();

  Future<Place> getById(String placeId);

  Future<void> create(Place place);

  Future<void> update(Place place);

  Future<void> delete(String placeId);

  Future<List<Purpose>> getAllPurposes();
}
