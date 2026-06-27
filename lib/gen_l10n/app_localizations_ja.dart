// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Stellar Archive';

  @override
  String get searchHint => 'キーワード検索...';

  @override
  String get emptyPlaces => '登録なし';

  @override
  String get urlNotRegistered => 'URLが登録されていません';

  @override
  String get urlCopied => 'URLをコピーしました';

  @override
  String get deleteConfirmTitle => '削除確認';

  @override
  String get deleteConfirmMessage => 'この場所を削除しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String fetchError(Object error) {
    return 'データ取得エラー: $error';
  }

  @override
  String get copyUrlTooltip => 'URLをコピー';

  @override
  String get detailTooltip => '詳細';

  @override
  String get placeDetailTitle => '場所の詳細';

  @override
  String get edit => '編集';

  @override
  String get registeredAt => '登録日時';

  @override
  String get memoPlaceholder => 'メモなし';

  @override
  String get openUrl => 'URLを開く';

  @override
  String get deleteSuccess => '場所を削除しました';

  @override
  String deleteError(Object error) {
    return '削除に失敗しました: $error';
  }

  @override
  String get retry => '再試行';
}
