import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

class UpdatePlaceUseCase {
  final PlaceRepository _repository;

  UpdatePlaceUseCase(this._repository);

  Future<void> execute(Place place) {
    return _repository.update(place);
  }
}
