import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/import_local_data_source.dart';
import 'package:seeking_my_place/features/place/data/repositories/import_repository_impl.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';

part 'import_repository.g.dart';

abstract class ImportRepository {
  Future<ImportResult> importAsDb();
}

@Riverpod(keepAlive: true)
ImportRepository importRepository(Ref ref) {
  final dataSource = ImportLocalDataSourceImpl(DatabaseHelper.instance);
  return ImportRepositoryImpl(dataSource);
}
