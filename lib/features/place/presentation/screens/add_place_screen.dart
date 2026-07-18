import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/usecases/create_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/fetch_tabelog_info_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_detail_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/update_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/validators/place_validator.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/place_form.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';
import 'package:seeking_my_place/shared/widgets/primary_button.dart';

// -----------------------------------------------------------------------------
// Screen
// -----------------------------------------------------------------------------

class AddPlaceScreen extends ConsumerWidget {
  const AddPlaceScreen({super.key, this.placeId});

  /// null → create mode / non-null → edit mode
  final String? placeId;

  bool get _isEditMode => placeId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = _isEditMode ? l10n.editPlaceTitle : l10n.addPlaceTitle;

    if (_isEditMode) {
      final placeAsync = ref.watch(getPlaceDetailUseCaseProvider(placeId!));
      return Scaffold(
        appBar: AppBarDefault(title: title),
        body: placeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            message: l10n.fetchError(error),
            onRetry: () =>
                ref.invalidate(getPlaceDetailUseCaseProvider(placeId!)),
          ),
          data: (place) => _AddPlaceBody(initialPlace: place),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarDefault(title: title, isModal: true),
      body: const _AddPlaceBody(),
    );
  }
}

// -----------------------------------------------------------------------------
// Body（フォーム本体）
// -----------------------------------------------------------------------------

class _AddPlaceBody extends ConsumerStatefulWidget {
  const _AddPlaceBody({this.initialPlace});

  final Place? initialPlace;

  @override
  ConsumerState<_AddPlaceBody> createState() => _AddPlaceBodyState();
}

class _AddPlaceBodyState extends ConsumerState<_AddPlaceBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _placeNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _urlController;
  late final TextEditingController _memoController;

  bool _isVisited = false;
  bool _isSaving = false;

  /// URLからの店舗情報取得中かどうか（画面全体のローディング表示に使用）。
  bool _isFetching = false;

  /// 現在取得中のURL。キャンセル時に対象プロバイダを特定して破棄するために保持する。
  String? _fetchingUrl;

  @override
  void initState() {
    super.initState();
    final place = widget.initialPlace;
    _placeNameController = TextEditingController(text: place?.placeName ?? '');
    _addressController = TextEditingController(text: place?.address ?? '');
    _latitudeController = TextEditingController(
      text: place != null ? place.latitude.toString() : '',
    );
    _longitudeController = TextEditingController(
      text: place != null ? place.longitude.toString() : '',
    );
    _urlController = TextEditingController(text: place?.url ?? '');
    _memoController = TextEditingController(text: place?.category ?? '');
    _isVisited = place?.isVisited ?? false;
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _urlController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Geocoding（住所 → 緯度経度）
  // ---------------------------------------------------------------------------

  Future<void> _onAddressInputCompleted() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    try {
      final locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        setState(() {
          _latitudeController.text = location.latitude.toString();
          _longitudeController.text = location.longitude.toString();
        });
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.geocodeError)));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 店舗情報の自動取得（URL → 名前・住所・ジャンル）
  // ---------------------------------------------------------------------------

  Future<void> _onTapFetchPlaceInfo() async {
    final l10n = AppLocalizations.of(context);
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.placeInfoUrlRequired)));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isFetching = true;
      _fetchingUrl = url;
    });

    try {
      final info = await ref.read(fetchTabelogInfoUseCaseProvider(url).future);
      // await の前後で必ず mounted を確認する。
      // 戻る操作でキャンセルされた場合は既に unmount 済みのためここで抜ける。
      if (!mounted) return;

      setState(() {
        if (info.name.isNotEmpty) _placeNameController.text = info.name;
        if (info.address.isNotEmpty) _addressController.text = info.address;
        if (info.genre.isNotEmpty) _memoController.text = info.genre;
        _isFetching = false;
        _fetchingUrl = null;
      });

      // 住所が取得できたら緯度・経度も続けて補完する。
      if (info.address.isNotEmpty) {
        await _onAddressInputCompleted();
      }
    } catch (e) {
      // キャンセルによる例外は unmount 済みで弾かれる。
      // ここに来るのは通信・パース失敗時のみ。入力は保持し、画面は閉じない。

      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _fetchingUrl = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.placeInfoFetchError)));
    }
  }

  /// 実行中の取得処理をキャンセルする。
  ///
  /// 対象プロバイダを [Ref.invalidate] で破棄することで、
  /// UseCase 側の [Ref.onDispose] が発火し、進行中の HTTP 通信が
  /// `CancelToken` によって中断される。
  void _cancelFetch() {
    final url = _fetchingUrl;
    if (url != null) {
      ref.invalidate(fetchTabelogInfoUseCaseProvider(url));
    }
    _isFetching = false;
    _fetchingUrl = null;
  }

  // ---------------------------------------------------------------------------
  // Validation
  //
  // バリデーションのビジネスルールはドメイン層の [PlaceValidator] に委譲し、
  // ここでは結果コード [PlaceValidationError] を l10n メッセージへ変換するのみ。
  // ---------------------------------------------------------------------------

  String? _validatePlaceName(String? value) =>
      _messageFor(PlaceValidator.validatePlaceName(value));

  String? _validateLatitude(String? value) =>
      _messageFor(PlaceValidator.validateLatitude(value));

  String? _validateLongitude(String? value) =>
      _messageFor(PlaceValidator.validateLongitude(value));

  String? _validateUrl(String? value) =>
      _messageFor(PlaceValidator.validateUrl(value));

  /// ドメインのバリデーション結果コードを、表示用の多言語メッセージへ変換する。
  String? _messageFor(PlaceValidationError? error) {
    if (error == null) return null;
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case PlaceValidationError.placeNameRequired:
        return l10n.validationPlaceNameRequired;
      case PlaceValidationError.latitudeRequired:
        return l10n.validationLatitudeRequired;
      case PlaceValidationError.latitudeFormat:
        return l10n.validationLatitudeFormat;
      case PlaceValidationError.latitudeRange:
        return l10n.validationLatitudeRange;
      case PlaceValidationError.longitudeRequired:
        return l10n.validationLongitudeRequired;
      case PlaceValidationError.longitudeFormat:
        return l10n.validationLongitudeFormat;
      case PlaceValidationError.longitudeRange:
        return l10n.validationLongitudeRange;
      case PlaceValidationError.urlRequired:
        return l10n.validationUrlRequired;
      case PlaceValidationError.urlFormat:
        return l10n.validationUrlFormat;
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _onTapSave() async {
    final l10n = AppLocalizations.of(context);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationErrorTitle)));
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final existingPlace = widget.initialPlace;
    final savedPlaceId =
        existingPlace?.placeId ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final place = Place(
      placeId: savedPlaceId,
      placeName: _placeNameController.text.trim(),
      address: _addressController.text.trim(),
      latitude: double.tryParse(_latitudeController.text) ?? 0.0,
      longitude: double.tryParse(_longitudeController.text) ?? 0.0,
      url: _urlController.text.trim(),
      category: _memoController.text.trim(),
      isVisited: _isVisited,
      createdAt: existingPlace?.createdAt ?? now,
      updatedAt: now,
      purposes: existingPlace?.purposes ?? [],
    );

    if (existingPlace == null) {
      await ref.read(createPlaceUseCaseProvider.notifier).execute(place);
      final resultState = ref.read(createPlaceUseCaseProvider);
      if (!mounted) return;
      if (resultState.hasError) {
        setState(() => _isSaving = false);
        _showSaveErrorDialog(l10n.saveError(resultState.error ?? ''));
        return;
      }
    } else {
      await ref.read(updatePlaceUseCaseProvider.notifier).execute(place);
      final resultState = ref.read(updatePlaceUseCaseProvider);
      if (!mounted) return;
      if (resultState.hasError) {
        setState(() => _isSaving = false);
        _showSaveErrorDialog(l10n.saveError(resultState.error ?? ''));
        return;
      }
    }

    ref.read(selectedPlaceStateProvider.notifier).select(savedPlaceId);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSaveErrorDialog(String message) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      // 取得中は自動で pop させず、いったん割り込んでキャンセル処理を挟む。
      canPop: !_isFetching,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 取得中に戻る操作が行われた場合：
        // 通信を中断 → ローディング解除 → 即座に前の画面へ戻る。
        _cancelFetch();
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          _buildForm(context, l10n),
          if (_isFetching) _buildLoadingOverlay(l10n),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ui.md AddPlaceScreen: Column > [PlaceForm, PrimaryButton("Save")]
            PlaceForm(
              formKey: _formKey,
              placeNameController: _placeNameController,
              categoryController: _memoController,
              urlController: _urlController,
              addressController: _addressController,
              latitudeController: _latitudeController,
              longitudeController: _longitudeController,
              isVisited: _isVisited,
              onVisitedChanged: (value) => setState(() => _isVisited = value),
              placeNameValidator: _validatePlaceName,
              latitudeValidator: _validateLatitude,
              longitudeValidator: _validateLongitude,
              urlValidator: _validateUrl,
              onAddressEditingComplete: _onAddressInputCompleted,
              initialPurposeId: widget.initialPlace?.purposes.isNotEmpty == true
                  ? widget.initialPlace!.purposes.first.purposeId
                  : null,
              urlSuffixIcon: IconButton(
                icon: const Icon(Icons.travel_explore),
                tooltip: l10n.placeInfoFetchTooltip,
                onPressed: _isFetching ? null : _onTapFetchPlaceInfo,
              ),
            ),
            const SizedBox(height: 24),

            // 保存ボタン
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(label: l10n.save, onPressed: _onTapSave),
          ],
        ),
      ),
    );
  }

  /// 取得通信中に画面全体を覆う半透明のローディングレイヤー。
  Widget _buildLoadingOverlay(AppLocalizations l10n) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 半透明の黒レイヤー。背後の操作を吸収する。
          const ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  l10n.placeInfoFetching,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Error view
// -----------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
