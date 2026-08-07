import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/export_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/repositories/export_repository_impl.dart';
import 'package:seeking_my_place/features/place/domain/entities/export_result.dart';

part 'export_repository.g.dart';

abstract class ExportRepository {
  Future<ExportResult> exportAsDb();
  Future<ExportResult> exportAsCsv();
  Future<ExportResult> exportAsTxt();
}

@Riverpod(keepAlive: true)
ExportRepository exportRepository(Ref ref) {
  final dataSource = ExportLocalDataSourceImpl(DatabaseHelper.instance);
  return ExportRepositoryImpl(dataSource);
}
