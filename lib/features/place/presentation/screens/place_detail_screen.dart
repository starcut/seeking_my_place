import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/usecases/delete_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_detail_use_case.dart';
import 'package:seeking_my_place/features/place/domain/validators/place_validator.dart';
import 'package:seeking_my_place/features/place/presentation/controller/place_info_fetch_service.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/place_form.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';
import 'package:seeking_my_place/shared/widgets/primary_button.dart';
import 'package:seeking_my_place/shared/widgets/secondary_button.dart';


class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  // View / Edit モードは AppBar からも切り替えるため、この親で保持する。
  _DetailMode _mode = _DetailMode.view;

  void _onTapEdit() => setState(() => _mode = _DetailMode.edit);

  void _switchToView() => setState(() => _mode = _DetailMode.view);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final placeId = widget.placeId;
    final placeAsync = ref.watch(getPlaceDetailUseCaseProvider(placeId));

    return Scaffold(
      appBar: AppBarDefault(
        title: l10n.placeDetailTitle,
        // 編集・削除アイコンは view モードのときのみ表示する。
        actions: _mode == _DetailMode.view
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.edit,
                  onPressed: _onTapEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.delete,
                  onPressed: () => _confirmDelete(context, ref, l10n),
                ),
              ]
            : null,
      ),
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: l10n.fetchError(error),
          onRetry: () => ref.invalidate(getPlaceDetailUseCaseProvider(placeId)),
        ),
        data: (place) => _PlaceDetailBody(
          place: place,
          mode: _mode,
          onSwitchToView: _switchToView,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final placeId = widget.placeId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(deletePlaceUseCaseProvider.notifier).execute(placeId);

    final deleteState = ref.read(deletePlaceUseCaseProvider);
    if (deleteState.hasError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteError(deleteState.error!))),
        );
      }
      return;
    }

    // 5.2.6: 削除対象が選択中だった場合は選択を解除する
    if (ref.read(selectedPlaceStateProvider) == placeId) {
      ref.read(selectedPlaceStateProvider.notifier).select(null);
    }

    if (context.mounted) {
      context.go('/');
    }
  }
}

// -----------------------------------------------------------------------------
// Body
// -----------------------------------------------------------------------------

/// 詳細画面のモード（閲覧 / 編集）。
enum _DetailMode { view, edit }

class _PlaceDetailBody extends ConsumerStatefulWidget {
  const _PlaceDetailBody({
    required this.place,
    required this.mode,
    required this.onSwitchToView,
  });

  final Place place;

  /// 現在の表示モード（親 [PlaceDetailScreen] が保持）。
  final _DetailMode mode;

  /// view モードへ戻すためのコールバック（Save / Cancel から呼ぶ）。
  final VoidCallback onSwitchToView;

  @override
  ConsumerState<_PlaceDetailBody> createState() => _PlaceDetailBodyState();
}

class _PlaceDetailBodyState extends ConsumerState<_PlaceDetailBody> {
  // 編集モード用の入力状態（この画面内モード切り替えのための UI 状態）。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _placeNameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _urlController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isVisited = false;
  bool _isSaving = false;

  late final PlaceInfoFetchService _fetchService;

  /// URLからの店舗情報取得中かどうか（画面全体のローディング表示に使用）。
  bool _isFetching = false;

  /// 現在取得中のURL。キャンセル時に対象プロバイダを特定して破棄するために保持する。
  String? _fetchingUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    _placeNameController = TextEditingController(text: p.placeName);
    _categoryController = TextEditingController(text: p.category);
    _urlController = TextEditingController(text: p.url);
    _addressController = TextEditingController(text: p.address);
    _latitudeController = TextEditingController(text: p.latitude.toString());
    _longitudeController = TextEditingController(text: p.longitude.toString());
    _isVisited = p.isVisited;
    _fetchService = PlaceInfoFetchService(ref);
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _categoryController.dispose();
    _urlController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Mode actions
  // ---------------------------------------------------------------------------

  void _onTapCancel() {
    // 変更を破棄して view に戻す。
    final p = widget.place;
    _placeNameController.text = p.placeName;
    _categoryController.text = p.category;
    _urlController.text = p.url;
    _addressController.text = p.address;
    _latitudeController.text = p.latitude.toString();
    _longitudeController.text = p.longitude.toString();
    setState(() => _isVisited = p.isVisited);
    widget.onSwitchToView();
  }

  void _onTapSave() {
    final l10n = AppLocalizations.of(context)!;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.validationErrorTitle)));
      return;
    }
    // NOTE: 更新ロジックは枠組みのみ。実データ更新の UseCase 呼び出しは
    // 既存ロジックを変更しないため本ステップでは行わず、view へ戻すのみとする。
    widget.onSwitchToView();
  }

  // ---------------------------------------------------------------------------
  // Validation（AddPlaceScreen と同様、ドメインの結果コードを l10n へ変換）
  // ---------------------------------------------------------------------------

  String? _validatePlaceName(String? value) =>
      _messageFor(PlaceValidator.validatePlaceName(value));

  String? _validateLatitude(String? value) =>
      _messageFor(PlaceValidator.validateLatitude(value));

  String? _validateLongitude(String? value) =>
      _messageFor(PlaceValidator.validateLongitude(value));

  String? _validateUrl(String? value) =>
      _messageFor(PlaceValidator.validateUrl(value));

  String? _messageFor(PlaceValidationError? error) {
    if (error == null) return null;
    final l10n = AppLocalizations.of(context)!;
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
      final info = await _fetchService.fetch(url);
      // await の前後で必ず mounted を確認する。
      // 戻る操作でキャンセルされた場合は既に unmount 済みのためここで抜ける。
      if (!mounted) return;

      setState(() {
        if (info.name.isNotEmpty) _placeNameController.text = info.name;
        if (info.address.isNotEmpty) _addressController.text = info.address;
        if (info.genre.isNotEmpty) _categoryController.text = info.genre;
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
      _fetchService.cancel(url);
    }
    _isFetching = false;
    _fetchingUrl = null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // view モードのときのみ通常どおり前の画面へ戻せる。
      canPop: widget.mode == _DetailMode.view,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 編集モード中の戻る操作は、編集を破棄して view モードへ戻す。
        _onTapCancel();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: widget.mode == _DetailMode.view
            ? _buildViewLayout(context)
            : _buildEditLayout(context),
      ),
    );
  }

  /// ViewLayout（ui.md 準拠。GoogleMapPreview は表示しない方針）。
  Widget _buildViewLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final place = widget.place;
    final categoryText = place.category.isEmpty ? l10n.notSet : place.category;
    final purposeText = place.purposes.isEmpty
        ? l10n.notSet
        : place.purposes.map((p) => p.purposeName).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // url
        if (place.url.isNotEmpty) ...[
          _UrlSection(place: place),
          const SizedBox(height: 16),
        ],
        // place_name
        _DetailSection(
          label: l10n.placeName,
          child: Text(
            place.placeName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        // category
        _DetailSection(
          label: l10n.category,
          child: Text(
            categoryText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        // purpose
        _DetailSection(
          label: l10n.purpose,
          child: Text(
            purposeText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        // AddressRow
        _DetailSection(
          label: l10n.address,
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // VisitedBadge
        _VisitedSection(isVisited: place.isVisited),
        const SizedBox(height: 16),
      ],
    );
  }

  /// EditLayout（ui.md 準拠: PlaceForm + Save + Cancel）。
  Widget _buildEditLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final place = widget.place;
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlaceForm(
                formKey: _formKey,
                placeNameController: _placeNameController,
                categoryController: _categoryController,
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
                initialPurposeId: place.purposes.isNotEmpty ? place.purposes.first.purposeId  : null,
                urlSuffixIcon: IconButton(
                  icon: const Icon(Icons.travel_explore),
                  tooltip: l10n.placeInfoFetchTooltip,
                  onPressed: _isFetching ? null : _onTapFetchPlaceInfo,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: l10n.save, onPressed: _onTapSave),
              const SizedBox(height: 12),
              SecondaryButton(label: l10n.cancel, onPressed: _onTapCancel),
            ],
          ),
        )
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-widgets
// -----------------------------------------------------------------------------

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        child,
        const Divider(),
      ],
    );
  }
}

class _VisitedSection extends StatelessWidget {
  const _VisitedSection({required this.isVisited});

  final bool isVisited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.visitedStatus,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Chip(
          avatar: Icon(
            isVisited ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isVisited ? Colors.green : Colors.grey,
          ),
          label: Text(
            isVisited ? l10n.isVisited : l10n.notVisited,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isVisited ? Colors.green : Colors.grey,
            ),
          ),
          backgroundColor: isVisited
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          side: BorderSide.none,
        ),
        const Divider(),
      ],
    );
  }
}

class _UrlSection extends ConsumerWidget {
  const _UrlSection({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        const Icon(Icons.link, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            place.url,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.blue),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: l10n.copyUrlTooltip,
          onPressed: () => _copyUrl(context, l10n),
        ),
      ],
    );
  }

  Future<void> _copyUrl(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: place.url));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.urlCopied)));
    }
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
    final l10n = AppLocalizations.of(context)!;

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
