import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

part 'create_place_use_case.g.dart';

@Riverpod(keepAlive: true)
class CreatePlaceUseCase extends _$CreatePlaceUseCase {
  @override
  FutureOr<void> build() {}

  Future<void> execute(Place place) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(placeRepositoryProvider).create(place),
    );
  }
}
