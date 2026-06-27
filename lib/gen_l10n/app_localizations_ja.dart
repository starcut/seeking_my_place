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
}
