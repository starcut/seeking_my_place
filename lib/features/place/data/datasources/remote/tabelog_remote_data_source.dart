import 'package:dio/dio.dart';
import 'package:seeking_my_place/features/place/domain/exceptions/tabelog_parse_exception.dart';

/// 食べログのページHTMLを外部から取得するデータソース。
///
/// 外部アクセス（HTTP通信）はこの層に閉じ込める。
abstract class TabelogRemoteDataSource {
  /// 指定した食べログURLのHTMLソースを文字列として取得する。
  ///
  /// 通信に失敗した場合（403 Forbidden を含む）は
  /// [TabelogParseException] を投げる。
  Future<String> fetchHtml(String url);
}

class TabelogRemoteDataSourceImpl implements TabelogRemoteDataSource {
  final Dio _dio;

  TabelogRemoteDataSourceImpl(this._dio);

  /// Bot判定を回避するため、一般的なChromeブラウザからのアクセスを
  /// 忠実に再現するリクエストヘッダー。
  static const Map<String, String> _browserHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,'
        'image/avif,image/webp,image/apng,*/*;q=0.8,'
        'application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
  };

  @override
  Future<String> fetchHtml(String url) async {
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          headers: _browserHeaders,
          responseType: ResponseType.plain,
          // 4xx/5xx でも例外にせず、後続で明示的に判定する。
          validateStatus: (status) => status != null && status < 500,
          followRedirects: true,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode != 200) {
        throw TabelogParseException(
          '食べログへのアクセスに失敗しました（HTTP $statusCode）。',
        );
      }

      final body = response.data;
      if (body == null || body.isEmpty) {
        throw const TabelogParseException('取得したHTMLが空でした。');
      }
      return body;
    } on TabelogParseException {
      rethrow;
    } on DioException catch (e) {
      throw TabelogParseException(
        '食べログとの通信中にエラーが発生しました。',
        cause: e,
      );
    }
  }
}
