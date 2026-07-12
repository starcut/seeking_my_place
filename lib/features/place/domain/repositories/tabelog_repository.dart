import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/data/datasources/remote/tabelog_remote_data_source.dart';
import 'package:seeking_my_place/features/place/data/repositories/tabelog_repository_impl.dart';
import 'package:seeking_my_place/features/place/domain/entities/tabelog_info.dart';

part 'tabelog_repository.g.dart';

abstract class TabelogRepository {
  /// 食べログURLから店舗情報（名前・住所・ジャンル）を取得する。
  Future<TabelogInfo> fetchInfo(String url);
}

@Riverpod(keepAlive: true)
TabelogRepository tabelogRepository(Ref ref) {
  final dataSource = TabelogRemoteDataSourceImpl(Dio());
  return TabelogRepositoryImpl(dataSource);
}
