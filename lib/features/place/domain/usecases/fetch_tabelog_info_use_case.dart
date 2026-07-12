import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seeking_my_place/features/place/domain/entities/tabelog_info.dart';
import 'package:seeking_my_place/features/place/domain/repositories/tabelog_repository.dart';

part 'fetch_tabelog_info_use_case.g.dart';

/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。
///
/// このプロバイダが `ref.invalidate` などで破棄されると、
/// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
/// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。
@riverpod
Future<TabelogInfo> fetchTabelogInfoUseCase(Ref ref, String url) async {
  final cancelToken = CancelToken();
  ref.onDispose(() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('fetchTabelogInfoUseCase was disposed');
    }
  });

  return ref
      .read(tabelogRepositoryProvider)
      .fetchInfo(url, cancelToken: cancelToken);
}
