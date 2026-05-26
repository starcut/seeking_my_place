import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

class GetPlaceListUseCase {
  final PlaceRepository _repository;

  GetPlaceListUseCase(this._repository);

  Future<List<Place>> execute() {
    return _repository.getAll();
  }
}
