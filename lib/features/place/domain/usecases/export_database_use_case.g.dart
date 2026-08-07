// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_database_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportDatabaseUseCase)
final exportDatabaseUseCaseProvider = ExportDatabaseUseCaseProvider._();

final class ExportDatabaseUseCaseProvider
    extends $AsyncNotifierProvider<ExportDatabaseUseCase, ExportResult?> {
  ExportDatabaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportDatabaseUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportDatabaseUseCaseHash();

  @$internal
  @override
  ExportDatabaseUseCase create() => ExportDatabaseUseCase();
}

String _$exportDatabaseUseCaseHash() =>
    r'422b1e851f8353172ed5b3b75e530b9a65445dfb';

abstract class _$ExportDatabaseUseCase extends $AsyncNotifier<ExportResult?> {
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
