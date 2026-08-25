import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/features/place/domain/entities/purpose.dart';
import 'package:seeking_my_place/features/place/domain/repositories/place_repository.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';

/// PlaceForm 用の目的リストを取得するプロバイダ（読み取り専用）。
///
/// 選択肢（options）の供給のみに使用し、既存の状態管理・保存ロジックには
/// 一切関与しない。
final placeFormPurposesProvider = FutureProvider.autoDispose<List<Purpose>>(
  (ref) => ref.watch(placeRepositoryProvider).getAllPurposes(),
);

/// ui.md「PlaceForm」に対応する共通フォームウィジェット。
///
/// 本ウィジェットは **レイアウト（Widget の配置）専用のラッパー** であり、
/// 状態（コントローラ・値・コールバック）はすべて呼び出し側の Screen が保持する。
/// ここでは受け取った値を ui.md の縦並び順で描画するだけに徹する。
///
/// レイアウト（縦並び）:
///   1. TextField(place_name)
///   2. TextField(category)
///   3. Dropdown(purpose)
///   4. TextField(url)
///   5. TextField(address)
///   6. MapPicker(latitude, longitude)  ← 既存の緯度/経度 TextField で表現
///   7. Checkbox(is_visited)
class PlaceForm extends ConsumerStatefulWidget {
  const PlaceForm({
    super.key,
    required this.formKey,
    required this.placeNameController,
    required this.categoryController,
    required this.urlController,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
    required this.isVisited,
    this.onVisitedChanged,
    this.readOnly = false,
    this.placeNameValidator,
    this.latitudeValidator,
    this.longitudeValidator,
    this.urlValidator,
    this.onAddressEditingComplete,
    this.onUrlEditingComplete,
    this.urlSuffixIcon,
    this.initialPurposeIds = const [],
    this.onPurposeChanged,
  });

  /// 呼び出し側が保持する FormState キー（バリデーションは呼び出し側で実行）。
  final GlobalKey<FormState> formKey;

  final TextEditingController placeNameController;

  /// category（本アプリでは従来 memo 相当のフリーテキスト）を保持するコントローラ。
  final TextEditingController categoryController;
  final TextEditingController urlController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  final bool isVisited;
  final ValueChanged<bool>? onVisitedChanged;

  /// true の場合、全フィールドを編集不可にする。
  final bool readOnly;

  final FormFieldValidator<String>? placeNameValidator;
  final FormFieldValidator<String>? latitudeValidator;
  final FormFieldValidator<String>? longitudeValidator;
  final FormFieldValidator<String>? urlValidator;

  final VoidCallback? onAddressEditingComplete;
  final VoidCallback? onUrlEditingComplete;

  /// URL フィールドの suffix（例: 自動取得ボタン）。呼び出し側から任意で差し込む。
  final Widget? urlSuffixIcon;

  /// 初期選択の purpose id リスト（複数選択）。
  final List<String> initialPurposeIds;
  final ValueChanged<List<String>>? onPurposeChanged;

  @override
  ConsumerState<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends ConsumerState<PlaceForm> {
  late List<String> _selectedPurposeIds;
  final MenuController _purposeMenuController = MenuController();

  @override
  void initState() {
    super.initState();
    _selectedPurposeIds = List<String>.from(widget.initialPurposeIds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readOnly = widget.readOnly;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. url
          TextFormField(
            controller: widget.urlController,
            decoration: InputDecoration(
              labelText: l10n.url,
              suffixIcon: _clearSuffix(
                widget.urlController,
                readOnly,
                extra: widget.urlSuffixIcon,
              ),
            ),
            readOnly: readOnly,
            keyboardType: TextInputType.url,
            validator: widget.urlValidator,
            textInputAction: TextInputAction.next,
            onEditingComplete: widget.onUrlEditingComplete,
          ),
          const SizedBox(height: 12),

          // 2. place_name
          TextFormField(
            controller: widget.placeNameController,
            decoration: InputDecoration(
              labelText: l10n.placeName,
              suffixIcon: _clearSuffix(widget.placeNameController, readOnly),
            ),
            readOnly: readOnly,
            validator: widget.placeNameValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 3. category
          TextFormField(
            controller: widget.categoryController,
            decoration: InputDecoration(
              labelText: l10n.category,
              suffixIcon: _clearSuffix(widget.categoryController, readOnly),
            ),
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 4. purpose（ドロップダウン形式のメニュー / provider から選択肢を取得。複数選択可）
          _buildPurposeDropdown(l10n, readOnly),
          const SizedBox(height: 12),

          // 5. address
          TextFormField(
            controller: widget.addressController,
            decoration: InputDecoration(
              labelText: l10n.address,
              suffixIcon: _clearSuffix(widget.addressController, readOnly),
            ),
            readOnly: readOnly,
            textInputAction: TextInputAction.done,
            onEditingComplete: widget.onAddressEditingComplete,
          ),
          const SizedBox(height: 12),

          // 6. MapPicker(latitude, longitude) ← 既存の緯度/経度 TextField
          // 手入力不可（プログラムからの値設定のみ許可）のため常に enabled: false。
          TextFormField(
            controller: widget.latitudeController,
            decoration: InputDecoration(
              labelText: l10n.latitude,
              suffixIcon: _clearSuffix(widget.latitudeController, true),
            ),
            enabled: false,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
            ],
            validator: widget.latitudeValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.longitudeController,
            decoration: InputDecoration(
              labelText: l10n.longitude,
              suffixIcon: _clearSuffix(widget.longitudeController, true),
            ),
            enabled: false,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
            ],
            validator: widget.longitudeValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 7. is_visited（Checkbox）
          CheckboxListTile(
            value: widget.isVisited,
            onChanged: readOnly
                ? null
                : (value) => widget.onVisitedChanged?.call(value ?? false),
            title: Text(l10n.isVisited),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// TextField 用の suffix を組み立てる。
  ///
  /// - 入力文字がある場合のみ「×」クリアボタンを表示する（readOnly 時は非表示）。
  /// - タップで [controller] をクリアする。
  /// - [extra] が渡された場合は「×」と横並びで表示する（例: URL 欄の取得ボタン）。
  ///
  /// 入力に追従して suffix だけを再描画するため [ValueListenableBuilder] を使う
  /// （listener の手動管理・dispose 不要。コントローラは親が所有する）。
  Widget _clearSuffix(
    TextEditingController controller,
    bool readOnly, {
    Widget? extra,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final showClear = !readOnly && value.text.isNotEmpty;
        final clearButton = showClear
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clear,
              )
            : null;

        final children = <Widget>[
          if (clearButton != null) clearButton,
          if (extra != null) extra,
        ];

        if (children.isEmpty) return const SizedBox.shrink();
        if (children.length == 1) return children.first;
        return Row(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  /// purpose ドロップダウンメニュー。選択肢は [placeFormPurposesProvider] から取得する。
  /// 項目をタップしてもメニューは閉じず、左のチェックの付け外しで複数選択できる。
  Widget _buildPurposeDropdown(AppLocalizations l10n, bool readOnly) {
    final purposesAsync = ref.watch(placeFormPurposesProvider);

    final purposes = purposesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Purpose>[],
    );

    final selectedNames = purposes
        .where((p) => _selectedPurposeIds.contains(p.purposeId))
        .map((p) => p.purposeName)
        .join(', ');

    return MenuAnchor(
      controller: _purposeMenuController,
      onOpen: () => setState(() {}),
      onClose: () => setState(() {}),
      menuChildren: purposes.map((p) {
        final checked = _selectedPurposeIds.contains(p.purposeId);
        return MenuItemButton(
          closeOnActivate: false,
          leadingIcon: Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          onPressed: readOnly
              ? null
              : () {
                  setState(() {
                    if (checked) {
                      _selectedPurposeIds.remove(p.purposeId);
                    } else {
                      _selectedPurposeIds.add(p.purposeId);
                    }
                  });
                  widget.onPurposeChanged?.call(
                    List.unmodifiable(_selectedPurposeIds),
                  );
                },
          child: Text(p.purposeName),
        );
      }).toList(),
      builder: (context, controller, child) {
        return InkWell(
          onTap: readOnly
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.purpose,
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                controller.isOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
              ),
            ),
            child: Text(
              selectedNames.isEmpty ? l10n.notSet : selectedNames,
            ),
          ),
        );
      },
    );
  }
}
