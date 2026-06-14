// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_app_settings_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateAppSettingsUseCase)
final updateAppSettingsUseCaseProvider = UpdateAppSettingsUseCaseProvider._();

final class UpdateAppSettingsUseCaseProvider
    extends $AsyncNotifierProvider<UpdateAppSettingsUseCase, void> {
  UpdateAppSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateAppSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateAppSettingsUseCaseHash();

  @$internal
  @override
  UpdateAppSettingsUseCase create() => UpdateAppSettingsUseCase();
}

String _$updateAppSettingsUseCaseHash() =>
    r'e2d4f418d4593cd54902934c8a57444839fcf520';

abstract class _$UpdateAppSettingsUseCase extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
