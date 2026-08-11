/// インポート処理の結果。
enum ImportResult {
  /// 選択した .db ファイルの取り込みが完了した。
  success,

  /// ユーザーがファイル選択を行わずに閉じた。
  cancelled,
}
