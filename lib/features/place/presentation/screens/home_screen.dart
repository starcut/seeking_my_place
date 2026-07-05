import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/usecases/delete_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_list_use_case.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  /// DraggableScrollableSheet の builder から受け取ったコントローラーを保持する。
  /// ref.listen 発火時にリストをスクロールするために使用する。
  ScrollController? _sheetScrollController;

  String _searchKeyword = '';
  bool _radiusEnabled = true;
  double _radiusMeter = 1000.0;
  Position? _currentPosition;

  /// ref.listen コールバック内でフィルター済みリストへアクセスするために保持する。
  /// build() 実行後に _buildBody() で更新されるため、listen 発火時点では
  /// 直前の build で確定したリストが入っている。
  List<Place> _lastFilteredPlaces = const [];

  static const double _listItemHeight = 88.0;
  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(35.6812, 139.7671),
    zoom: 12,
  );

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Location
  // -------------------------------------------------------------------------

  Future<void> _fetchCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    if (mounted) setState(() => _currentPosition = position);
  }

  // -------------------------------------------------------------------------
  // Filter
  // -------------------------------------------------------------------------

  List<Place> _filterPlaces(List<Place> places) {
    var result = places;

    if (_searchKeyword.isNotEmpty) {
      final lowerCaseKeyword = _searchKeyword.toLowerCase();
      result = result.where((place) {
        return place.placeName.toLowerCase().contains(lowerCaseKeyword) ||
            place.address.toLowerCase().contains(lowerCaseKeyword);
      }).toList();
    }

    if (_radiusEnabled && _currentPosition != null) {
      result = result.where((place) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          place.latitude,
          place.longitude,
        );
        return distance <= _radiusMeter;
      }).toList();
    }

    return result;
  }

  // -------------------------------------------------------------------------
  // Map helpers
  // -------------------------------------------------------------------------

  Set<Marker> _buildMarkers(List<Place> places, String? selectedId) {
    return places.map((place) {
      final isSelected = place.placeId == selectedId;
      return Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.latitude, place.longitude),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: place.placeName, snippet: place.address),
        onTap: () {
          ref.read(selectedPlaceStateProvider.notifier).select(place.placeId);
        },
      );
    }).toSet();
  }

  Set<Circle> _buildCircles() {
    if (!_radiusEnabled || _currentPosition == null) return {};
    return {
      Circle(
        circleId: const CircleId('radius_overlay'),
        center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radius: _radiusMeter,
        fillColor: Colors.blue.withOpacity(0.10),
        strokeColor: Colors.blue.withOpacity(0.40),
        strokeWidth: 1,
      ),
    };
  }

  void _moveCameraTo(Place place) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(place.latitude, place.longitude)),
    );
  }

  // -------------------------------------------------------------------------
  // List helpers
  // -------------------------------------------------------------------------

  void _scrollToIndex(int index) {
    final controller = _sheetScrollController;
    if (controller == null || !controller.hasClients) return;
    final targetOffset = index * _listItemHeight;
    controller.animateTo(
      targetOffset.clamp(0.0, controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _copyUrl(Place place) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (place.url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.urlNotRegistered)));
      return;
    }
    await Clipboard.setData(ClipboardData(text: place.url));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.urlCopied)));
    }
  }

  Future<void> _deletePlace(String placeId) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
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

    // 削除対象が選択中だった場合は選択を解除する (spec 5.2.4)
    if (ref.read(selectedPlaceStateProvider) == placeId) {
      ref.read(selectedPlaceStateProvider.notifier).select(null);
    }
    ref.invalidate(getPlaceListUseCaseProvider);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(getPlaceListUseCaseProvider);
    final selectedId = ref.watch(selectedPlaceStateProvider);

    // selectedPlaceId が変化したとき Map カメラ移動 + リストスクロール (spec 5.1.4)
    ref.listen<String?>(selectedPlaceStateProvider, (previousId, nextId) {
      if (nextId == null || nextId == previousId) return;
      final targetIndex = _lastFilteredPlaces.indexWhere(
        (place) => place.placeId == nextId,
      );
      if (targetIndex < 0) return;
      _moveCameraTo(_lastFilteredPlaces[targetIndex]);
      _scrollToIndex(targetIndex);
    });

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarDefault(
        title: l10n.appTitle,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.fetchError(error))),
        data: (places) => _buildBody(places, selectedId),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/place/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(List<Place> places, String? selectedId) {
    final filteredPlaces = _filterPlaces(places);
    _lastFilteredPlaces = filteredPlaces;

    // フィルター適用で選択中 Place が除外されたら選択を解除する (spec 5.1.4)
    if (selectedId != null &&
        !filteredPlaces.any((place) => place.placeId == selectedId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedPlaceStateProvider.notifier).select(null);
        }
      });
    }

    final initialCamera = _currentPosition != null
        ? CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 14,
          )
        : _defaultCameraPosition;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCamera,
          markers: _buildMarkers(filteredPlaces, selectedId),
          circles: _buildCircles(),
          myLocationEnabled: _currentPosition != null,
          myLocationButtonEnabled: _currentPosition != null,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (_) {
            ref.read(selectedPlaceStateProvider.notifier).select(null);
          },
          onLongPress: (latLng) {
            context.push(
              '/place/new',
              extra: {
                'latitude': latLng.latitude,
                'longitude': latLng.longitude,
              },
            );
          },
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (sheetContext, sheetScrollController) {
            _sheetScrollController = sheetScrollController;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const _DragHandle(),
                  _HomeSearchBar(
                    controller: _searchController,
                    keyword: _searchKeyword,
                    onChanged: (keyword) =>
                        setState(() => _searchKeyword = keyword),
                  ),
                  _RadiusFilterBar(
                    enabled: _radiusEnabled,
                    radiusMeter: _radiusMeter,
                    onEnabledChanged: (isEnabled) =>
                        setState(() => _radiusEnabled = isEnabled),
                    onRadiusChanged: (radius) =>
                        setState(() => _radiusMeter = radius),
                  ),
                  Expanded(
                    child: _buildPlaceList(
                      filteredPlaces,
                      selectedId,
                      sheetScrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceList(
    List<Place> places,
    String? selectedId,
    ScrollController scrollController,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (places.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(l10n.emptyPlaces),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: places.length,
      itemExtent: _listItemHeight,
      itemBuilder: (itemContext, index) {
        final place = places[index];
        final isSelected = place.placeId == selectedId;

        return Slidable(
          key: ValueKey(place.placeId),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => _deletePlace(place.placeId),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: l10n.delete,
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () {
              ref
                  .read(selectedPlaceStateProvider.notifier)
                  .select(place.placeId);
            },
            child: Container(
              color: isSelected
                  ? const Color(0xFFFFF2B8)
                  : Theme.of(itemContext).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (place.category.isNotEmpty)
                              Text(
                                place.category,
                                style: Theme.of(
                                  itemContext,
                                ).textTheme.labelSmall,
                              ),
                            const Spacer(),
                            if (place.isVisited)
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                          ],
                        ),
                        Text(
                          place.placeName,
                          style: Theme.of(itemContext).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          place.address,
                          style: Theme.of(itemContext).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.link, size: 20),
                    onPressed: () => _copyUrl(place),
                    tooltip: l10n.copyUrlTooltip,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () => context.push('/place/${place.placeId}'),
                    tooltip: l10n.detailTooltip,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Private sub-widgets
// -----------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({
    required this.controller,
    required this.keyword,
    required this.onChanged,
  });

  final TextEditingController controller;

  /// 親が保持するキーワード文字列。クリアボタンの表示制御に使用する。
  final String keyword;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: onChanged,
              ),
            ),
            if (keyword.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: const Icon(Icons.clear, color: Colors.grey, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadiusFilterBar extends StatelessWidget {
  const _RadiusFilterBar({
    required this.enabled,
    required this.radiusMeter,
    required this.onEnabledChanged,
    required this.onRadiusChanged,
  });

  final bool enabled;
  final double radiusMeter;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onRadiusChanged;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters.toStringAsFixed(0)}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: radiusMeter,
              min: 100,
              max: 50000,
              onChanged: enabled ? onRadiusChanged : null,
            ),
          ),
          Text(
            _formatDistance(radiusMeter),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 4),
          Switch(value: enabled, onChanged: onEnabledChanged),
        ],
      ),
    );
  }
}
