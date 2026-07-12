import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:seeking_my_place/features/place/data/datasources/remote/tabelog_remote_data_source.dart';
import 'package:seeking_my_place/features/place/domain/entities/tabelog_info.dart';
import 'package:seeking_my_place/features/place/domain/exceptions/tabelog_parse_exception.dart';
import 'package:seeking_my_place/features/place/domain/repositories/tabelog_repository.dart';

class TabelogRepositoryImpl implements TabelogRepository {
  final TabelogRemoteDataSource _dataSource;

  TabelogRepositoryImpl(this._dataSource);

  /// 食べログのホスト名。
  static const String _tabelogHost = 'tabelog.com';

  @override
  Future<TabelogInfo> fetchInfo(String url) async {
    _validateTabelogUrl(url);

    final rawHtml = await _dataSource.fetchHtml(url);

    final Document document;
    try {
      document = html_parser.parse(rawHtml);
    } catch (e) {
      throw TabelogParseException('HTMLの解析に失敗しました。', cause: e);
    }

    final name = _extractName(document);
    final address = _extractAddress(document);
    final genre = _extractGenre(document);

    if (name.isEmpty && address.isEmpty && genre.isEmpty) {
      throw const TabelogParseException(
        '店舗情報を抽出できませんでした。ページ構造が変更された可能性があります。',
      );
    }

    return TabelogInfo(name: name, address: address, genre: genre);
  }

  /// 食べログ以外のURLが渡された場合は例外を投げる。
  void _validateTabelogUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw TabelogParseException('無効なURLです: $url');
    }
    final host = uri.host.toLowerCase();
    final isTabelog = host == _tabelogHost || host.endsWith('.$_tabelogHost');
    if (!isTabelog) {
      throw TabelogParseException('食べログのURLではありません: $url');
    }
  }

  /// 店舗名を抽出する（例: `h2.display-name`）。
  String _extractName(Document document) {
    return _firstText(document, const ['h2.display-name']);
  }

  /// 住所を抽出する（例: `p.rstinfo-table__address`）。
  String _extractAddress(Document document) {
    return _firstText(document, const ['p.rstinfo-table__address']);
  }

  /// ジャンルを抽出する（例: `span.rstinfo-table__sub-info`）。
  String _extractGenre(Document document) {
    return _firstText(document, const ['span.rstinfo-table__sub-info']);
  }

  /// 与えられたCSSセレクタ群を順に試し、最初に見つかった要素の
  /// 整形済みテキストを返す。見つからなければ空文字を返す。
  String _firstText(Document document, List<String> selectors) {
    for (final selector in selectors) {
      final element = document.querySelector(selector);
      final text = element?.text;
      if (text != null && text.trim().isNotEmpty) {
        return _normalize(text);
      }
    }
    return '';
  }

  /// 連続する空白・改行を1つの半角スペースに畳んでトリムする。
  String _normalize(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
