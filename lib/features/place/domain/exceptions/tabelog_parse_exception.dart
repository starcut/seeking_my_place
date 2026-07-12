/// 食べログの店舗情報取得・解析に失敗した場合に投げる例外。
///
/// - 食べログ以外のURLが渡された場合
/// - 通信エラー（403 Forbidden 等を含む）が発生した場合
/// - HTMLのパースに失敗（対象要素が見つからない等）した場合
class TabelogParseException implements Exception {
  /// 失敗理由の説明。
  final String message;

  /// 元となった例外（存在する場合）。
  final Object? cause;

  const TabelogParseException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'TabelogParseException: $message (cause: $cause)';
    }
    return 'TabelogParseException: $message';
  }
}
