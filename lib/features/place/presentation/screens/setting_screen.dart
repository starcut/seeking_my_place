import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:seeking_my_place/features/place/domain/entities/export_result.dart';
import 'package:seeking_my_place/features/place/domain/entities/import_result.dart';
import 'package:seeking_my_place/features/place/domain/usecases/export_csv_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/export_database_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/export_txt_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/import_database_use_case.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';
import 'package:seeking_my_place/shared/widgets/app_dialog.dart';

/// SettingScreen (spec 5.4 / ui.md 9)
///
/// UI 先行実装フェーズのためビジネスロジックは未接続。
/// エクスポート形式の選択のみ画面内 State で切り替わる簡易実装とし、
/// ファイル選択は debugPrint のモックとする。
/// エクスポート（db 形式）は [ExportDatabaseUseCase] に接続済み。
class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  /// エクスポート形式の選択肢 (spec 5.4)。
  static const List<String> _exportFormatOptions = ['db', 'csv', 'txt'];

  /// 現在選択中のエクスポート形式。
  String _selectedExportFormat = 'db';

  /// pubspec.yaml (seeking_my_place) のバージョン。package_info_plus から取得する。
  String _appVersion = '';

  /// この画面を開いている間にインポートが成功したかどうか。
  /// 画面を閉じる際にこの値を返し、呼び出し元 (HomeScreen) で場所一覧の
  /// 再取得を行うために使う。
  bool _hasImported = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = info.version);
    }
  }

  /// エクスポートボタン押下時の処理。選択中の形式ごとに分岐する。
  Future<void> _onExportPressed() async {
    switch (_selectedExportFormat) {
      case 'db':
        await _exportAsDb();
        break;
      case 'csv':
        await _exportAsCsv();
        break;
      case 'txt':
        await _exportAsTxt();
      default:
        break;
    }
  }

  /// place_list のみを含む .db ファイルを共有シート (ActionSheet) 経由で
  /// 書き出す。
  Future<void> _exportAsDb() async {
    await ref.read(exportDatabaseUseCaseProvider.notifier).execute();
    if (!mounted) return;
    _showExportResultSnackBar(ref.read(exportDatabaseUseCaseProvider));
  }

  /// place_list を .csv ファイルとして共有シート (ActionSheet) 経由で書き出す。
  Future<void> _exportAsCsv() async {
    await ref.read(exportCsvUseCaseProvider.notifier).execute();
    if (!mounted) return;
    _showExportResultSnackBar(ref.read(exportCsvUseCaseProvider));
  }

  /// place_list の内容（紐づく purpose 名を含む）を .txt ファイルとして
  /// 共有シート (ActionSheet) 経由で書き出す。
  Future<void> _exportAsTxt() async {
    await ref.read(exportTxtUseCaseProvider.notifier).execute();
    if (!mounted) return;
    _showExportResultSnackBar(ref.read(exportTxtUseCaseProvider));
  }

  /// 選択した .db ファイルの place_list をアプリのデータベースへ取り込む。
  /// PlaceId は既存データと重複しない値を新たに発行して登録する。
  Future<void> _importDbFile() async {
    await ref.read(importDatabaseUseCaseProvider.notifier).execute();
    if (!mounted) return;
    final resultState = ref.read(importDatabaseUseCaseProvider);
    if (resultState.value == ImportResult.success) {
      _hasImported = true;
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AppDialog(
          title: l10n.importSuccessTitle,
          message: l10n.importSuccess,
          actions: [
            AppDialogAction(
              label: l10n.close,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(_hasImported);
      return;
    }
    _showImportResultSnackBar(resultState);
  }

  /// エクスポート結果に応じたメッセージを SnackBar で表示する。
  void _showExportResultSnackBar(AsyncValue<ExportResult?> resultState) {
    final l10n = AppLocalizations.of(context)!;

    if (resultState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportError(resultState.error ?? ''))),
      );
      return;
    }

    final message = switch (resultState.value) {
      ExportResult.success => l10n.exportSuccess,
      ExportResult.cancelled => l10n.exportCancelled,
      ExportResult.unavailable || null => l10n.exportUnavailable,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// インポート結果に応じたメッセージを SnackBar で表示する。
  void _showImportResultSnackBar(AsyncValue<ImportResult?> resultState) {
    final l10n = AppLocalizations.of(context)!;

    if (resultState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importError(resultState.error ?? ''))),
      );
      return;
    }

    final message = switch (resultState.value) {
      ImportResult.success => l10n.importSuccess,
      ImportResult.cancelled || null => l10n.importCancelled,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_hasImported);
      },
      child: Scaffold(
        appBar: AppBarDefault(title: l10n.settingTitle),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DataSection(
              exportFormatOptions: _exportFormatOptions,
              selectedExportFormat: _selectedExportFormat,
              onExportFormatChanged: (value) {
                if (value != null) {
                  setState(() => _selectedExportFormat = value);
                }
              },
              onExport: _onExportPressed,
              onImport: _importDbFile,
              appVersion: _appVersion,
            ),
          ],
        ),
      ),
    );
  }
}

/// DataSection: エクスポート・インポート・バージョンの各行 (ui.md 9)
///
/// 各行は [MainAxisAlignment.spaceBetween] で両端に広げ、行間は [Divider] で区切る。
class _DataSection extends StatelessWidget {
  const _DataSection({
    required this.exportFormatOptions,
    required this.selectedExportFormat,
    required this.onExportFormatChanged,
    required this.onExport,
    required this.onImport,
    required this.appVersion,
  });

  final List<String> exportFormatOptions;
  final String selectedExportFormat;
  final ValueChanged<String?> onExportFormatChanged;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final String appVersion;

  static const Divider _divider = Divider(height: 32, thickness: 0.5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // エクスポート
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.exportButton),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedExportFormat,
                  items: exportFormatOptions.map((format) {
                    return DropdownMenuItem<String>(
                      value: format,
                      child: Text(format),
                    );
                  }).toList(),
                  onChanged: onExportFormatChanged,
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onExport,
                  child: Text(l10n.exportRun),
                ),
              ],
            ),
          ],
        ),
        _divider,
        // インポート（左側はラベル + 対応形式の注意書きを縦並び）
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.importButton),
                const SizedBox(height: 2),
                Text(
                  l10n.importSupportedFormats,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onImport,
              child: Text(l10n.importSelectFile),
            ),
          ],
        ),
        _divider,
        // バージョン
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.versionLabel),
            Text(
              appVersion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
