// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_csv_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportCsvUseCase)
final exportCsvUseCaseProvider = ExportCsvUseCaseProvider._();

final class ExportCsvUseCaseProvider
    extends $AsyncNotifierProvider<ExportCsvUseCase, ExportResult?> {
  ExportCsvUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportCsvUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportCsvUseCaseHash();

  @$internal
  @override
  ExportCsvUseCase create() => ExportCsvUseCase();
}

String _$exportCsvUseCaseHash() => r'09afe63d3c18374aabcd9263da00b1575871b5b7';

abstract class _$ExportCsvUseCase extends $AsyncNotifier<ExportResult?> {
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
