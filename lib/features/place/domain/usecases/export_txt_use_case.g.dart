// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_txt_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportTxtUseCase)
final exportTxtUseCaseProvider = ExportTxtUseCaseProvider._();

final class ExportTxtUseCaseProvider
    extends $AsyncNotifierProvider<ExportTxtUseCase, ExportResult?> {
  ExportTxtUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportTxtUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportTxtUseCaseHash();

  @$internal
  @override
  ExportTxtUseCase create() => ExportTxtUseCase();
}

String _$exportTxtUseCaseHash() => r'9afdbff0019be3831eac2fe013a673a762a001ca';

abstract class _$ExportTxtUseCase extends $AsyncNotifier<ExportResult?> {
  FutureOr<ExportResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExportResult?>, ExportResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExportResult?>, ExportResult?>,
              AsyncValue<ExportResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
