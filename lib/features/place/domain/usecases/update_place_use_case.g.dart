// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_place_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdatePlaceUseCase)
final updatePlaceUseCaseProvider = UpdatePlaceUseCaseProvider._();

final class UpdatePlaceUseCaseProvider
    extends $AsyncNotifierProvider<UpdatePlaceUseCase, void> {
  UpdatePlaceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePlaceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePlaceUseCaseHash();

  @$internal
  @override
  UpdatePlaceUseCase create() => UpdatePlaceUseCase();
}

String _$updatePlaceUseCaseHash() =>
    r'fb9209823a371d5075b39d38ba9f05f0c22e9dd7';

abstract class _$UpdatePlaceUseCase extends $AsyncNotifier<void> {
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
