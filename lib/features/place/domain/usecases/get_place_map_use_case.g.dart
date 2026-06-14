// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_place_map_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getPlaceMapUseCase)
final getPlaceMapUseCaseProvider = GetPlaceMapUseCaseProvider._();

final class GetPlaceMapUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Place>>,
          Map<String, Place>,
          FutureOr<Map<String, Place>>
        >
    with
        $FutureModifier<Map<String, Place>>,
        $FutureProvider<Map<String, Place>> {
  GetPlaceMapUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPlaceMapUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPlaceMapUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, Place>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Place>> create(Ref ref) {
    return getPlaceMapUseCase(ref);
  }
}

String _$getPlaceMapUseCaseHash() =>
    r'e69da842019af7bf83c7fda9fb2fd1f834000b2d';
