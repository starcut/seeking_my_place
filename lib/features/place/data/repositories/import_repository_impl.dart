import 'package:seeking_my_place/features/place/data/datasources/local/import_local_data_source.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';
import 'package:seeking_my_place/features/place/domain/repositories/import_repository.dart';

class ImportRepositoryImpl implements ImportRepository {
  final ImportLocalDataSource _dataSource;

  ImportRepositoryImpl(this._dataSource);

  @override
  Future<ImportResult> importAsJson() {
    return _dataSource.importJsonFile();
  }
}
