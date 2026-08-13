import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';
import 'package:seeking_my_place/features/place/domain/repositories/import_repository.dart';

part 'import_json_use_case.g.dart';

@Riverpod(keepAlive: true)
class ImportJsonUseCase extends _$ImportJsonUseCase {
  @override
  FutureOr<ImportResult?> build() => null;

  Future<void> execute() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(importRepositoryProvider).importAsJson(),
    );
  }
}
