// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_place_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeletePlaceUseCase)
final deletePlaceUseCaseProvider = DeletePlaceUseCaseProvider._();

final class DeletePlaceUseCaseProvider
    extends $AsyncNotifierProvider<DeletePlaceUseCase, void> {
  DeletePlaceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePlaceUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletePlaceUseCaseHash();

  @$internal
  @override
  DeletePlaceUseCase create() => DeletePlaceUseCase();
}

String _$deletePlaceUseCaseHash() =>
    r'a3f9d36f11aff25decd576f61c4d5443167da1d2';

abstract class _$DeletePlaceUseCase extends $AsyncNotifier<void> {
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
