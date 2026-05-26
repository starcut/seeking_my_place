// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_place_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedPlaceState)
final selectedPlaceStateProvider = SelectedPlaceStateProvider._();

final class SelectedPlaceStateProvider
    extends $NotifierProvider<SelectedPlaceState, String?> {
  SelectedPlaceStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPlaceStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPlaceStateHash();

  @$internal
  @override
  SelectedPlaceState create() => SelectedPlaceState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedPlaceStateHash() =>
    r'1f8df6a3d7c668f05aa6e1f612502dc4b5ec062d';

abstract class _$SelectedPlaceState extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
