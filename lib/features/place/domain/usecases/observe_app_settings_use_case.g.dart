// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observe_app_settings_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ObserveAppSettingsUseCase)
final observeAppSettingsUseCaseProvider = ObserveAppSettingsUseCaseProvider._();

final class ObserveAppSettingsUseCaseProvider
    extends $NotifierProvider<ObserveAppSettingsUseCase, AppSettings> {
  ObserveAppSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observeAppSettingsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observeAppSettingsUseCaseHash();

  @$internal
  @override
  ObserveAppSettingsUseCase create() => ObserveAppSettingsUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$observeAppSettingsUseCaseHash() =>
    r'e5ad2759f886f9d27698269a701ad6db80d80f6a';

abstract class _$ObserveAppSettingsUseCase extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
