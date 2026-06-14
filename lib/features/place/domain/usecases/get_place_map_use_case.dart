import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

part 'get_place_map_use_case.g.dart';

@riverpod
Future<Map<String, Place>> getPlaceMapUseCase(Ref ref) async {
  final places = await ref.read(placeRepositoryProvider).getAll();
  return {for (final p in places) p.placeId: p};
}
