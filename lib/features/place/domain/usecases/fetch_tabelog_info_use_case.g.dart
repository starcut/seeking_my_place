// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_tabelog_info_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。

@ProviderFor(fetchTabelogInfoUseCase)
final fetchTabelogInfoUseCaseProvider = FetchTabelogInfoUseCaseFamily._();

/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。

final class FetchTabelogInfoUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<TabelogInfo>,
          TabelogInfo,
          FutureOr<TabelogInfo>
        >
    with $FutureModifier<TabelogInfo>, $FutureProvider<TabelogInfo> {
  /// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
  ///
  /// 取得・解析に失敗した場合は `TabelogParseException` を投げる。
  FetchTabelogInfoUseCaseProvider._({
    required FetchTabelogInfoUseCaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fetchTabelogInfoUseCaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchTabelogInfoUseCaseHash();

  @override
  String toString() {
    return r'fetchTabelogInfoUseCaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TabelogInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TabelogInfo> create(Ref ref) {
    final argument = this.argument as String;
    return fetchTabelogInfoUseCase(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchTabelogInfoUseCaseProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchTabelogInfoUseCaseHash() =>
    r'5c8f1424724e25e03e33800c632e79a07f8952c8';

/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。

final class FetchTabelogInfoUseCaseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TabelogInfo>, String> {
  FetchTabelogInfoUseCaseFamily._()
    : super(
        retry: null,
        name: r'fetchTabelogInfoUseCaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
  ///
  /// 取得・解析に失敗した場合は `TabelogParseException` を投げる。

  FetchTabelogInfoUseCaseProvider call(String url) =>
      FetchTabelogInfoUseCaseProvider._(argument: url, from: this);

  @override
  String toString() => r'fetchTabelogInfoUseCaseProvider';
}
