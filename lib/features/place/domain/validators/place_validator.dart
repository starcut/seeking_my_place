/// 場所フォームのバリデーション結果コード。
///
/// ドメイン層に属するため、プレゼンテーション層（UI / l10n）やアプリケーション層
/// （Riverpod 等）へは依存しない。表示用のメッセージへの変換はプレゼンテーション層
/// が本 enum を受け取って行う。
enum PlaceValidationError {
  placeNameRequired,
  latitudeRequired,
  latitudeFormat,
  latitudeRange,
  longitudeRequired,
  longitudeFormat,
  longitudeRange,
  urlRequired,
  urlFormat,
}

/// 場所エンティティの入力値バリデーション（ドメインのビジネスルール）。
///
/// UI に依存しない純粋なロジックのみを持つ。各メソッドは検証に成功した場合 `null`、
/// 失敗した場合は該当する [PlaceValidationError] を返す。
class PlaceValidator {
  const PlaceValidator._();

  static const double latitudeMin = -90.0;
  static const double latitudeMax = 90.0;
  static const double longitudeMin = -180.0;
  static const double longitudeMax = 180.0;

  /// 場所の名前: 必須（トリム後、空文字不可）。
  static PlaceValidationError? validatePlaceName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PlaceValidationError.placeNameRequired;
    }
    return null;
  }

  /// 緯度: 必須、数値変換可能、かつ [latitudeMin] 〜 [latitudeMax] の範囲。
  static PlaceValidationError? validateLatitude(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return PlaceValidationError.latitudeRequired;
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return PlaceValidationError.latitudeFormat;
    if (parsed < latitudeMin || parsed > latitudeMax) {
      return PlaceValidationError.latitudeRange;
    }
    return null;
  }

  /// 経度: 必須、数値変換可能、かつ [longitudeMin] 〜 [longitudeMax] の範囲。
  static PlaceValidationError? validateLongitude(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return PlaceValidationError.longitudeRequired;
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return PlaceValidationError.longitudeFormat;
    if (parsed < longitudeMin || parsed > longitudeMax) {
      return PlaceValidationError.longitudeRange;
    }
    return null;
  }

  /// URL: 必須。http / https 形式かつホストを持つこと。
  static PlaceValidationError? validateUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return PlaceValidationError.urlRequired;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (!uri.isScheme('http') && !uri.isScheme('https')) ||
        uri.host.isEmpty) {
      return PlaceValidationError.urlFormat;
    }
    return null;
  }
}
