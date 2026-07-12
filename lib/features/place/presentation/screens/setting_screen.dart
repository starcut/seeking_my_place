import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';

/// SettingScreen (spec 5.4 / ui.md 9)
///
/// UI 先行実装フェーズのためビジネスロジックは未接続。
/// 表示件数・エクスポート形式の選択のみ画面内 State で切り替わる簡易実装とし、
/// 書き出し / ファイル選択は debugPrint のモックとする。
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  /// 表示件数の選択肢。
  /// null は「制限なし」を表し、データ上も null を保存する (spec 5.4)。
  static const List<int?> _itemsPerPageOptions = [
    10,
    20,
    30,
    50,
    100,
    500,
    1000,
    null,
  ];

  /// エクスポート形式の選択肢 (spec 5.4)。
  static const List<String> _exportFormatOptions = ['db', 'csv', 'txt'];

  /// 現在選択中の表示件数。null は「制限なし」。
  int? _selectedItemsPerPage = 10;

  /// 現在選択中のエクスポート形式。
  String _selectedExportFormat = 'db';

  /// pubspec.yaml (seeking_my_place) のバージョン。package_info_plus から取得する。
  String _appVersion = '';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarDefault(title: l10n.settingTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DataSection(
            itemsPerPageOptions: _itemsPerPageOptions,
            selectedItemsPerPage: _selectedItemsPerPage,
            onItemsPerPageChanged: (value) =>
                setState(() => _selectedItemsPerPage = value),
            exportFormatOptions: _exportFormatOptions,
            selectedExportFormat: _selectedExportFormat,
            onExportFormatChanged: (value) {
              if (value != null) {
                setState(() => _selectedExportFormat = value);
              }
            },
            onExport: () => debugPrint('export database (mock)'),
            onImport: () => debugPrint('import database (mock)'),
            appVersion: _appVersion,
          ),
        ],
      ),
    );
  }
}

/// DataSection: 表示件数・エクスポート・インポート・バージョンの各行 (ui.md 9)
///
/// 各行は [MainAxisAlignment.spaceBetween] で両端に広げ、行間は [Divider] で区切る。
class _DataSection extends StatelessWidget {
  const _DataSection({
    required this.itemsPerPageOptions,
    required this.selectedItemsPerPage,
    required this.onItemsPerPageChanged,
    required this.exportFormatOptions,
    required this.selectedExportFormat,
    required this.onExportFormatChanged,
    required this.onExport,
    required this.onImport,
    required this.appVersion,
  });

  final List<int?> itemsPerPageOptions;
  final int? selectedItemsPerPage;
  final ValueChanged<int?> onItemsPerPageChanged;
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
        // 表示件数
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.itemsPerPageLabel),
            Row(
              children: [
                DropdownButton<int?>(
                  value: selectedItemsPerPage,
                  items: itemsPerPageOptions.map((value) {
                    return DropdownMenuItem<int?>(
                      value: value,
                      child: Text(
                        value?.toString() ?? l10n.itemsPerPageUnlimited,
                      ),
                    );
                  }).toList(),
                  onChanged: onItemsPerPageChanged,
                ),
                const SizedBox(width: 8),
                Text(l10n.itemsPerPageUnit),
              ],
            ),
          ],
        ),
        _divider,
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
