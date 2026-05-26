import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

class DeletePlaceUseCase {
  final PlaceRepository _repository;

  DeletePlaceUseCase(this._repository);

  Future<void> execute(String placeId) {
    return _repository.delete(placeId);
  }
}
