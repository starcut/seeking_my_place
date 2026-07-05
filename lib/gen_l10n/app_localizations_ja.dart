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

  @override
  String get addPlaceTitle => '場所を追加';

  @override
  String get editPlaceTitle => '場所を編集';

  @override
  String get save => '保存';

  @override
  String get placeName => '場所の名前';

  @override
  String get address => '住所';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '経度';

  @override
  String get url => 'URL';

  @override
  String get memo => 'メモ';

  @override
  String get isVisited => '訪問済み';

  @override
  String get validationErrorTitle => '入力エラー';

  @override
  String get validationPlaceNameRequired => '場所の名前は必須です';

  @override
  String get validationLatitudeRange => '緯度は -90 〜 90 の範囲で入力してください';

  @override
  String get validationLongitudeRange => '経度は -180 〜 180 の範囲で入力してください';

  @override
  String get validationUrlFormat => '正しい URL 形式で入力してください';

  @override
  String get validationLatitudeFormat => '緯度は数値で入力してください';

  @override
  String get validationLongitudeFormat => '経度は数値で入力してください';

  @override
  String saveError(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get saveErrorTitle => '保存エラー';

  @override
  String get close => '閉じる';

  @override
  String get geocodeError => '住所から座標を取得できませんでした';

  @override
  String get notVisited => '未訪問';

  @override
  String get visitedStatus => '訪問状況';
}
