// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_place_list_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getPlaceListUseCase)
final getPlaceListUseCaseProvider = GetPlaceListUseCaseProvider._();

final class GetPlaceListUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Place>>,
          List<Place>,
          FutureOr<List<Place>>
        >
    with $FutureModifier<List<Place>>, $FutureProvider<List<Place>> {
  GetPlaceListUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPlaceListUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPlaceListUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<List<Place>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Place>> create(Ref ref) {
    return getPlaceListUseCase(ref);
  }
}

String _$getPlaceListUseCaseHash() =>
    r'7397cb46aead074dd262f734e79afbbcc235ca6a';
