// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_database_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImportDatabaseUseCase)
final importDatabaseUseCaseProvider = ImportDatabaseUseCaseProvider._();

final class ImportDatabaseUseCaseProvider
    extends $AsyncNotifierProvider<ImportDatabaseUseCase, ImportResult?> {
  ImportDatabaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importDatabaseUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importDatabaseUseCaseHash();

  @$internal
  @override
  ImportDatabaseUseCase create() => ImportDatabaseUseCase();
}

String _$importDatabaseUseCaseHash() =>
    r'7465a9c4eb0f8d4119262c237e27a229bfec7ffd';

abstract class _$ImportDatabaseUseCase extends $AsyncNotifier<ImportResult?> {
  FutureOr<ImportResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ImportResult?>, ImportResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ImportResult?>, ImportResult?>,
              AsyncValue<ImportResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
