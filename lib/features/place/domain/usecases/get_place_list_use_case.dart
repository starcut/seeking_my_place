import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

part 'get_place_list_use_case.g.dart';

@riverpod
Future<List<Place>> getPlaceListUseCase(Ref ref) async {
  return await ref.watch(placeRepositoryProvider).getAll();
}
