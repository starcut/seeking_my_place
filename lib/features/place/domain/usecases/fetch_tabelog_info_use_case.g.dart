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
///
/// このプロバイダが `ref.invalidate` などで破棄されると、
/// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
/// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。

@ProviderFor(fetchTabelogInfoUseCase)
final fetchTabelogInfoUseCaseProvider = FetchTabelogInfoUseCaseFamily._();

/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。
///
/// このプロバイダが `ref.invalidate` などで破棄されると、
/// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
/// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。

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
  ///
  /// このプロバイダが `ref.invalidate` などで破棄されると、
  /// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
  /// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。
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
    r'82c1f2be580c7d39110e3852440bb90b39bffff5';

/// 食べログURLを受け取り、店舗情報（名前・住所・ジャンル）を取得する。
///
/// 取得・解析に失敗した場合は `TabelogParseException` を投げる。
///
/// このプロバイダが `ref.invalidate` などで破棄されると、
/// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
/// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。

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
  ///
  /// このプロバイダが `ref.invalidate` などで破棄されると、
  /// [Ref.onDispose] を通じて実行中の通信が [CancelToken] でキャンセルされる。
  /// これにより、画面を閉じたあとにバックグラウンドで通信が走り続けるのを防ぐ。

  FetchTabelogInfoUseCaseProvider call(String url) =>
      FetchTabelogInfoUseCaseProvider._(argument: url, from: this);

  @override
  String toString() => r'fetchTabelogInfoUseCaseProvider';
}
