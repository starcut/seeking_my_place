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
    this.urlSuffixIcon,
    this.initialPurposeId,
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

  /// URL フィールドの suffix（例: 自動取得ボタン）。呼び出し側から任意で差し込む。
  final Widget? urlSuffixIcon;

  /// 初期選択の purpose id。
  final String? initialPurposeId;
  final ValueChanged<String?>? onPurposeChanged;

  @override
  ConsumerState<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends ConsumerState<PlaceForm> {
  String? _selectedPurposeId;

  @override
  void initState() {
    super.initState();
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
              suffixIcon: widget.urlSuffixIcon,
            ),
            readOnly: readOnly,
            keyboardType: TextInputType.url,
            validator: widget.urlValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 2. place_name
          TextFormField(
            controller: widget.placeNameController,
            decoration: InputDecoration(labelText: l10n.placeName),
            readOnly: readOnly,
            validator: widget.placeNameValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 3. category
          TextFormField(
            controller: widget.categoryController,
            decoration: InputDecoration(labelText: l10n.category),
            readOnly: readOnly,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // 4. purpose（Dropdown / provider から選択肢を取得）
          _buildPurposeDropdown(l10n, readOnly),
          const SizedBox(height: 12),

          // 5. address
          TextFormField(
            controller: widget.addressController,
            decoration: InputDecoration(labelText: l10n.address),
            readOnly: readOnly,
            textInputAction: TextInputAction.done,
            onEditingComplete: widget.onAddressEditingComplete,
          ),
          const SizedBox(height: 12),

          // 6. MapPicker(latitude, longitude) ← 既存の緯度/経度 TextField
          TextFormField(
            controller: widget.latitudeController,
            decoration: InputDecoration(labelText: l10n.latitude),
            readOnly: readOnly,
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
            decoration: InputDecoration(labelText: l10n.longitude),
            readOnly: readOnly,
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

  /// purpose ドロップダウン。選択肢は [placeFormPurposesProvider] から取得する。
  Widget _buildPurposeDropdown(AppLocalizations l10n, bool readOnly) {
    final purposesAsync = ref.watch(placeFormPurposesProvider);

    final purposes = purposesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Purpose>[],
    );

    return DropdownButtonFormField<String>(
      initialValue: _selectedPurposeId,
      decoration: InputDecoration(labelText: l10n.purpose),
      hint: Text(l10n.notSet),
      items: purposes
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.purposeId,
              child: Text(p.purposeName),
            ),
          )
          .toList(),
      onChanged: readOnly
          ? null
          : (value) {
              setState(() => _selectedPurposeId = value);
              widget.onPurposeChanged?.call(value);
            },
    );
  }
}
