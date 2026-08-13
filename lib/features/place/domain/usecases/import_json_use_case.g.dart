// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_json_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImportJsonUseCase)
final importJsonUseCaseProvider = ImportJsonUseCaseProvider._();

final class ImportJsonUseCaseProvider
    extends $AsyncNotifierProvider<ImportJsonUseCase, ImportResult?> {
  ImportJsonUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importJsonUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importJsonUseCaseHash();

  @$internal
  @override
  ImportJsonUseCase create() => ImportJsonUseCase();
}

String _$importJsonUseCaseHash() => r'4fb7fe93336775ed332cafeccde8a32874329fcc';

abstract class _$ImportJsonUseCase extends $AsyncNotifier<ImportResult?> {
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
