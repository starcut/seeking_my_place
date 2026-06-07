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
        isAutoDispose: true,
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
    r'39c341e6da0e8925665ee9c9dda38f9b0f2f94bb';

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
