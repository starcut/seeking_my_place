import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/usecases/create_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_detail_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/update_place_use_case.dart';
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
  // Validation
  // ---------------------------------------------------------------------------

  String? _validatePlaceName(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.validationPlaceNameRequired;
    }
    return null;
  }

  String? _validateLatitude(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return l10n.validationLatitudeFormat;
    if (parsed < -90 || parsed > 90) return l10n.validationLatitudeRange;
    return null;
  }

  String? _validateLongitude(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return l10n.validationLongitudeFormat;
    if (parsed < -180 || parsed > 180) return l10n.validationLongitudeRange;
    return null;
  }

  String? _validateUrl(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return l10n.validationUrlFormat;
    }
    return null;
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(labelText: l10n.url),
                keyboardType: TextInputType.url,
                validator: _validateUrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // 場所の名前
              TextFormField(
                controller: _placeNameController,
                decoration: InputDecoration(labelText: l10n.placeName),
                validator: _validatePlaceName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // 住所
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: l10n.address),
                textInputAction: TextInputAction.done,
                onEditingComplete: _onAddressInputCompleted,
              ),
              const SizedBox(height: 12),

              // 緯度
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: l10n.latitude),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                validator: _validateLatitude,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // 経度
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: l10n.longitude),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                validator: _validateLongitude,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // 訪問済み
              CheckboxListTile(
                value: _isVisited,
                onChanged: (value) =>
                    setState(() => _isVisited = value ?? false),
                title: Text(l10n.isVisited),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),

              // メモ
              TextFormField(
                controller: _memoController,
                decoration: InputDecoration(labelText: l10n.memo),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 24),

              // 保存ボタン
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(label: l10n.save, onPressed: _onTapSave),
            ],
          ),
        ),
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
