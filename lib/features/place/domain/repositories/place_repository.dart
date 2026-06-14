import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/place_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/repositories/place_repository_impl.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/entities/purpose.dart';

part 'place_repository.g.dart';

abstract class PlaceRepository {
  Future<List<Place>> getAll();

  Future<Place> getById(String placeId);

  Future<void> create(Place place);

  Future<void> update(Place place);

  Future<void> delete(String placeId);

  Future<List<Purpose>> getAllPurposes();
}

@Riverpod(keepAlive: true)
PlaceRepository placeRepository(Ref ref) {
  final dataSource = PlaceLocalDataSourceImpl(DatabaseHelper.instance);
  return PlaceRepositoryImpl(dataSource);
}
