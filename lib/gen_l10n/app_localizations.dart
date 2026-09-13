import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'道行の手記'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In ja, this message translates to:
  /// **'キーワード検索...'**
  String get searchHint;

  /// No description provided for @emptyPlaces.
  ///
  /// In ja, this message translates to:
  /// **'登録なし'**
  String get emptyPlaces;

  /// No description provided for @urlNotRegistered.
  ///
  /// In ja, this message translates to:
  /// **'URLが登録されていません'**
  String get urlNotRegistered;

  /// No description provided for @urlCopied.
  ///
  /// In ja, this message translates to:
  /// **'URLをコピーしました'**
  String get urlCopied;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'削除確認'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'この場所を削除しますか？'**
  String get deleteConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @fetchError.
  ///
  /// In ja, this message translates to:
  /// **'データ取得エラー: {error}'**
  String fetchError(Object error);

  /// No description provided for @copyUrlTooltip.
  ///
  /// In ja, this message translates to:
  /// **'URLをコピー'**
  String get copyUrlTooltip;

  /// No description provided for @detailTooltip.
  ///
  /// In ja, this message translates to:
  /// **'詳細'**
  String get detailTooltip;

  /// No description provided for @placeDetailTitle.
  ///
  /// In ja, this message translates to:
  /// **'場所の詳細'**
  String get placeDetailTitle;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @registeredAt.
  ///
  /// In ja, this message translates to:
  /// **'登録日時'**
  String get registeredAt;

  /// No description provided for @memoPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'メモなし'**
  String get memoPlaceholder;

  /// No description provided for @openUrl.
  ///
  /// In ja, this message translates to:
  /// **'URLを開く'**
  String get openUrl;

  /// No description provided for @deleteSuccess.
  ///
  /// In ja, this message translates to:
  /// **'場所を削除しました'**
  String get deleteSuccess;

  /// No description provided for @deleteError.
  ///
  /// In ja, this message translates to:
  /// **'削除に失敗しました: {error}'**
  String deleteError(Object error);

  /// No description provided for @retry.
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get retry;

  /// No description provided for @addPlaceTitle.
  ///
  /// In ja, this message translates to:
  /// **'場所を追加'**
  String get addPlaceTitle;

  /// No description provided for @editPlaceTitle.
  ///
  /// In ja, this message translates to:
  /// **'場所を編集'**
  String get editPlaceTitle;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @placeName.
  ///
  /// In ja, this message translates to:
  /// **'場所の名前'**
  String get placeName;

  /// No description provided for @address.
  ///
  /// In ja, this message translates to:
  /// **'住所'**
  String get address;

  /// No description provided for @latitude.
  ///
  /// In ja, this message translates to:
  /// **'緯度'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In ja, this message translates to:
  /// **'経度'**
  String get longitude;

  /// No description provided for @url.
  ///
  /// In ja, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @urlHint.
  ///
  /// In ja, this message translates to:
  /// **'食べログのページ https://s.tabelog.com/...'**
  String get urlHint;

  /// No description provided for @memo.
  ///
  /// In ja, this message translates to:
  /// **'メモ'**
  String get memo;

  /// No description provided for @validationErrorTitle.
  ///
  /// In ja, this message translates to:
  /// **'入力エラー'**
  String get validationErrorTitle;

  /// No description provided for @validationPlaceNameRequired.
  ///
  /// In ja, this message translates to:
  /// **'場所の名前は必須です'**
  String get validationPlaceNameRequired;

  /// No description provided for @validationLatitudeRequired.
  ///
  /// In ja, this message translates to:
  /// **'緯度は必須です'**
  String get validationLatitudeRequired;

  /// No description provided for @validationLongitudeRequired.
  ///
  /// In ja, this message translates to:
  /// **'経度は必須です'**
  String get validationLongitudeRequired;

  /// No description provided for @validationUrlRequired.
  ///
  /// In ja, this message translates to:
  /// **'URLは必須です'**
  String get validationUrlRequired;

  /// No description provided for @validationLatitudeRange.
  ///
  /// In ja, this message translates to:
  /// **'緯度は -90 〜 90 の範囲で入力してください'**
  String get validationLatitudeRange;

  /// No description provided for @validationLongitudeRange.
  ///
  /// In ja, this message translates to:
  /// **'経度は -180 〜 180 の範囲で入力してください'**
  String get validationLongitudeRange;

  /// No description provided for @validationUrlFormat.
  ///
  /// In ja, this message translates to:
  /// **'正しい URL 形式で入力してください'**
  String get validationUrlFormat;

  /// No description provided for @validationUrlTabelogRequired.
  ///
  /// In ja, this message translates to:
  /// **'食べログのページ（「tabelog.com」が含まれているURL）を入力してください'**
  String get validationUrlTabelogRequired;

  /// No description provided for @tabelogDomain.
  ///
  /// In ja, this message translates to:
  /// **'tabelog.com'**
  String get tabelogDomain;

  /// No description provided for @validationLatitudeFormat.
  ///
  /// In ja, this message translates to:
  /// **'緯度は数値で入力してください'**
  String get validationLatitudeFormat;

  /// No description provided for @validationLongitudeFormat.
  ///
  /// In ja, this message translates to:
  /// **'経度は数値で入力してください'**
  String get validationLongitudeFormat;

  /// No description provided for @saveError.
  ///
  /// In ja, this message translates to:
  /// **'保存に失敗しました: {error}'**
  String saveError(Object error);

  /// No description provided for @saveErrorTitle.
  ///
  /// In ja, this message translates to:
  /// **'保存エラー'**
  String get saveErrorTitle;

  /// No description provided for @saveSuccessTitle.
  ///
  /// In ja, this message translates to:
  /// **'保存完了'**
  String get saveSuccessTitle;

  /// No description provided for @saveSuccessMessage.
  ///
  /// In ja, this message translates to:
  /// **'場所を保存しました'**
  String get saveSuccessMessage;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @geocodeError.
  ///
  /// In ja, this message translates to:
  /// **'住所から座標を取得できませんでした'**
  String get geocodeError;

  /// No description provided for @isVisited.
  ///
  /// In ja, this message translates to:
  /// **'訪問済み'**
  String get isVisited;

  /// No description provided for @notVisited.
  ///
  /// In ja, this message translates to:
  /// **'未訪問'**
  String get notVisited;

  /// No description provided for @visitedStatus.
  ///
  /// In ja, this message translates to:
  /// **'訪問状況'**
  String get visitedStatus;

  /// No description provided for @settingTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingTitle;

  /// No description provided for @itemsPerPageLabel.
  ///
  /// In ja, this message translates to:
  /// **'表示件数'**
  String get itemsPerPageLabel;

  /// No description provided for @itemsPerPageUnit.
  ///
  /// In ja, this message translates to:
  /// **'件'**
  String get itemsPerPageUnit;

  /// No description provided for @itemsPerPageUnlimited.
  ///
  /// In ja, this message translates to:
  /// **'制限なし'**
  String get itemsPerPageUnlimited;

  /// No description provided for @exportButton.
  ///
  /// In ja, this message translates to:
  /// **'エクスポート'**
  String get exportButton;

  /// No description provided for @importButton.
  ///
  /// In ja, this message translates to:
  /// **'インポート'**
  String get importButton;

  /// No description provided for @exportRun.
  ///
  /// In ja, this message translates to:
  /// **'書き出し'**
  String get exportRun;

  /// No description provided for @importSelectFile.
  ///
  /// In ja, this message translates to:
  /// **'ファイル選択'**
  String get importSelectFile;

  /// No description provided for @importSupportedFormats.
  ///
  /// In ja, this message translates to:
  /// **'対応形式：.json'**
  String get importSupportedFormats;

  /// No description provided for @versionLabel.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get versionLabel;

  /// No description provided for @appVersion.
  ///
  /// In ja, this message translates to:
  /// **'バージョン {version}'**
  String appVersion(String version);

  /// No description provided for @settingScreenReserved.
  ///
  /// In ja, this message translates to:
  /// **''**
  String get settingScreenReserved;

  /// No description provided for @placeInfoFetching.
  ///
  /// In ja, this message translates to:
  /// **'店舗情報を取得中...'**
  String get placeInfoFetching;

  /// No description provided for @placeInfoFetchTooltip.
  ///
  /// In ja, this message translates to:
  /// **'URLから店舗情報を取得'**
  String get placeInfoFetchTooltip;

  /// No description provided for @placeInfoFetchError.
  ///
  /// In ja, this message translates to:
  /// **'店舗情報の取得に失敗しました。URLをご確認ください'**
  String get placeInfoFetchError;

  /// No description provided for @placeInfoUrlRequired.
  ///
  /// In ja, this message translates to:
  /// **'URLを入力してください'**
  String get placeInfoUrlRequired;

  /// No description provided for @category.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリー'**
  String get category;

  /// No description provided for @purpose.
  ///
  /// In ja, this message translates to:
  /// **'利用目的'**
  String get purpose;

  /// No description provided for @notSet.
  ///
  /// In ja, this message translates to:
  /// **'未設定'**
  String get notSet;

  /// No description provided for @exportSuccess.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートが完了しました'**
  String get exportSuccess;

  /// No description provided for @exportCancelled.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートをキャンセルしました'**
  String get exportCancelled;

  /// No description provided for @exportUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'エクスポート処理を実行しました'**
  String get exportUnavailable;

  /// No description provided for @exportError.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートに失敗しました: {error}'**
  String exportError(Object error);

  /// No description provided for @importSuccessTitle.
  ///
  /// In ja, this message translates to:
  /// **'インポート完了'**
  String get importSuccessTitle;

  /// No description provided for @importSuccess.
  ///
  /// In ja, this message translates to:
  /// **'インポートが完了しました'**
  String get importSuccess;

  /// No description provided for @importCancelled.
  ///
  /// In ja, this message translates to:
  /// **'インポートをキャンセルしました'**
  String get importCancelled;

  /// No description provided for @importError.
  ///
  /// In ja, this message translates to:
  /// **'インポートに失敗しました: {error}'**
  String importError(Object error);

  /// No description provided for @searchRangeLabel.
  ///
  /// In ja, this message translates to:
  /// **'検索範囲'**
  String get searchRangeLabel;

  /// No description provided for @filterDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'絞り込み'**
  String get filterDialogTitle;

  /// No description provided for @purposeMultiSelectLabel.
  ///
  /// In ja, this message translates to:
  /// **'目的（複数選択可）'**
  String get purposeMultiSelectLabel;

  /// No description provided for @resetButton.
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get resetButton;

  /// No description provided for @applyButton.
  ///
  /// In ja, this message translates to:
  /// **'適用'**
  String get applyButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
