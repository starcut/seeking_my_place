// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_place_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreatePlaceUseCase)
final createPlaceUseCaseProvider = CreatePlaceUseCaseProvider._();

final class CreatePlaceUseCaseProvider
    extends $AsyncNotifierProvider<CreatePlaceUseCase, void> {
  CreatePlaceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPlaceUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPlaceUseCaseHash();

  @$internal
  @override
  CreatePlaceUseCase create() => CreatePlaceUseCase();
}

String _$createPlaceUseCaseHash() =>
    r'66335967648cbc3218216ddbee0dec8639a8fa2c';

abstract class _$CreatePlaceUseCase extends $AsyncNotifier<void> {
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
