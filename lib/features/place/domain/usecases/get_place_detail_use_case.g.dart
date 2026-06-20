// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_place_detail_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getPlaceDetailUseCase)
final getPlaceDetailUseCaseProvider = GetPlaceDetailUseCaseFamily._();

final class GetPlaceDetailUseCaseProvider
    extends $FunctionalProvider<AsyncValue<Place>, Place, FutureOr<Place>>
    with $FutureModifier<Place>, $FutureProvider<Place> {
  GetPlaceDetailUseCaseProvider._({
    required GetPlaceDetailUseCaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getPlaceDetailUseCaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getPlaceDetailUseCaseHash();

  @override
  String toString() {
    return r'getPlaceDetailUseCaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Place> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Place> create(Ref ref) {
    final argument = this.argument as String;
    return getPlaceDetailUseCase(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetPlaceDetailUseCaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getPlaceDetailUseCaseHash() =>
    r'62bf3f4f5a6e16f89f6e11bcc0ea19aee790ef7a';

final class GetPlaceDetailUseCaseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Place>, String> {
  GetPlaceDetailUseCaseFamily._()
    : super(
        retry: null,
        name: r'getPlaceDetailUseCaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetPlaceDetailUseCaseProvider call(String placeId) =>
      GetPlaceDetailUseCaseProvider._(argument: placeId, from: this);

  @override
  String toString() => r'getPlaceDetailUseCaseProvider';
}
