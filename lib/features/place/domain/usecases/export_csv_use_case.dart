import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/export_result.dart';
import 'package:seeking_my_place/features/place/domain/repositories/export_repository.dart';

part 'export_csv_use_case.g.dart';

@Riverpod(keepAlive: true)
class ExportCsvUseCase extends _$ExportCsvUseCase {
  @override
  FutureOr<ExportResult?> build() => null;

  Future<void> execute() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(exportRepositoryProvider).exportAsCsv(),
    );
  }
}
