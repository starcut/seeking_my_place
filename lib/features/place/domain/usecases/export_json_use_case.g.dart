// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_json_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportJsonUseCase)
final exportJsonUseCaseProvider = ExportJsonUseCaseProvider._();

final class ExportJsonUseCaseProvider
    extends $AsyncNotifierProvider<ExportJsonUseCase, ExportResult?> {
  ExportJsonUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportJsonUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportJsonUseCaseHash();

  @$internal
  @override
  ExportJsonUseCase create() => ExportJsonUseCase();
}

String _$exportJsonUseCaseHash() => r'86f9a294705567fbae6bfa2ab574b8308542a76d';

abstract class _$ExportJsonUseCase extends $AsyncNotifier<ExportResult?> {
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
