import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

class CreatePlaceUseCase {
  final PlaceRepository _repository;

  CreatePlaceUseCase(this._repository);

  Future<void> execute(Place place) {
    return _repository.create(place);
  }
}
