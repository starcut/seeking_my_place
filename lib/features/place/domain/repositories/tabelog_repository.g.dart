// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabelog_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tabelogRepository)
final tabelogRepositoryProvider = TabelogRepositoryProvider._();

final class TabelogRepositoryProvider
    extends
        $FunctionalProvider<
          TabelogRepository,
          TabelogRepository,
          TabelogRepository
        >
    with $Provider<TabelogRepository> {
  TabelogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabelogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabelogRepositoryHash();

  @$internal
  @override
  $ProviderElement<TabelogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TabelogRepository create(Ref ref) {
    return tabelogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabelogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabelogRepository>(value),
    );
  }
}

String _$tabelogRepositoryHash() => r'124eca21d02e24fb36dc13b6ad3cb20727554246';
