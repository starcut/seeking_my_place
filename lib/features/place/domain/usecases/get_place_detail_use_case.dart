import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

part 'get_place_detail_use_case.g.dart';

@riverpod
Future<Place> getPlaceDetailUseCase(Ref ref, String placeId) async {
  return ref.read(placeRepositoryProvider).getById(placeId);
}
