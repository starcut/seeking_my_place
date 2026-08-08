import 'package:seeking_my_place/features/place/data/datasources/local/export_local_data_source.dart';
import 'package:seeking_my_place/features/place/domain/entities/export_result.dart';
import 'package:seeking_my_place/features/place/domain/repositories/export_repository.dart';
import 'package:share_plus/share_plus.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportLocalDataSource _dataSource;

  ExportRepositoryImpl(this._dataSource);

  @override
  Future<ExportResult> exportAsDb() async {
    final status = await _dataSource.exportDatabaseFile();
    return _toExportResult(status);
  }

  @override
  Future<ExportResult> exportAsCsv() async {
    final status = await _dataSource.exportCsvFiles();
    return _toExportResult(status);
  }

  @override
  Future<ExportResult> exportAsTxt() async {
    final status = await _dataSource.exportTxtFile();
    return _toExportResult(status);
  }

  ExportResult _toExportResult(ShareResultStatus status) {
    return switch (status) {
      ShareResultStatus.success => ExportResult.success,
      ShareResultStatus.dismissed => ExportResult.cancelled,
      ShareResultStatus.unavailable => ExportResult.unavailable,
    };
  }
}
