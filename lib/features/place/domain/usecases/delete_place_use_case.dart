import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';

part 'delete_place_use_case.g.dart';

@riverpod
class DeletePlaceUseCase extends _$DeletePlaceUseCase {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(placeRepositoryProvider).delete(id),
    );
  }
}
