import 'package:riverpod_annotation/riverpod_annotation.dart';
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

@riverpod
PlaceRepository placeRepository(Ref ref) {
  // ここで「実際の実装クラス」を返す必要がある
  // 例: return PlaceRepositoryImpl();
  throw UnimplementedError('Repositoryの実装クラスがProviderに登録されていません');
}
