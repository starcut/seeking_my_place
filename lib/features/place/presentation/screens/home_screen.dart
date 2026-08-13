import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/enums/purpose_icon.dart';
import 'package:seeking_my_place/features/place/domain/usecases/delete_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_list_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/observe_app_settings_use_case.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/filter_dialog.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/home_screen_sub_widgets.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/home_search_bar.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/place_cell.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/radius_filter_bar.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';
import 'package:seeking_my_place/shared/widgets/app_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  /// 場所一覧 (ListView) 専用の ScrollController。
  ///
  /// DraggableScrollableSheet の builder が渡すコントローラーはリストには使わない。
  /// あのコントローラーをリストに渡すと「リストが先頭までスクロールされた状態で
  /// さらにドラッグするとシートが伸縮する」という標準の連動挙動が有効になり、
  /// リスト領域のスワイプでもシートの高さが変わってしまう。
  /// 高さ調整はつまみ ([_onHandleDragUpdate] 等) のみで行うため、リストは独立した
  /// このコントローラーを使う。
  final ScrollController _placeListScrollController = ScrollController();

  /// つまみのドラッグで DraggableScrollableSheet の childSize を直接操作するための
  /// コントローラー。
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// つまみを離した後、GoogleMap のパン操作のような慣性で childSize を収束させる
  /// ための AnimationController。値をそのまま childSize として使用する。
  late final AnimationController _flingController;

  /// DragHandle + 検索欄 + 半径フィルターバーの実際の描画高さを測定するための Key。
  /// minChildSize (検索欄 + セル2行分) の計算に使用する。
  final GlobalKey _headerKey = GlobalKey();
  double? _headerHeight;

  /// DraggableScrollableSheet が配置されている領域 (GoogleMap と同じ Stack) の高さ。
  double _sheetContainerHeight = 0;

  double _minChildSize = 0.15;
  double _maxChildSize = 0.6667;
  double _initialChildSize = 0.4;

  String _searchKeyword = '';
  bool _radiusEnabled = true;
  double _radiusMeter = 1000.0;

  /// 表示件数の選択肢。
  /// null は「制限なし」を表す。
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

  /// 表示件数のデフォルト値。絞り込みダイアログのリセット時にも使用する。
  static const int? _defaultItemsPerPage = 10;

  /// 現在選択中の表示件数。null は「制限なし」。
  int? _selectedItemsPerPage = _defaultItemsPerPage;

  Set<VisitStatus> _visitedStatuses = {};
  String _category = '';
  Set<PurposeIcon> _selectedPurposes = {};

  Position? _currentPosition;

  /// GoogleMap 上に現在地 (青い点) と現在地ボタンを表示するかどうか。
  bool _showCurrentLocation = true;

  /// GoogleMap 中央 (十字カーソル) が指す座標。ピンやリストの絞り込み範囲の中心に使う。
  LatLng? _mapCenter;

  /// ref.listen コールバック内でフィルター済みリストへアクセスするために保持する。
  /// build() 実行後に _buildBody() で更新されるため、listen 発火時点では
  /// 直前の build で確定したリストが入っている。
  List<Place> _lastFilteredPlaces = const [];

  /// [Slidable] の onDismissed が発火した後、非表示にしておく placeId の集合。
  ///
  /// ref.invalidate は再取得を開始するだけで、完了までは直前のリストが
  /// 表示され続けるため、削除済みのセルが一瞬再ビルドされてしまい
  /// "A dismissed Slidable widget is still part of the tree." エラーになる。
  /// これを避けるため、onDismissed 時点で即座にここへ追加してリストから除外する。
  final Set<String> _dismissedPlaceIds = {};

  static const double _listItemHeight = 88.0;

  /// FloatingActionButton とセルが重ならないように確保する下部の余白。
  static const double _fabReservedHeight = 100.0;

  static const double _sheetCornerRadius = 16.0;
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
    _radiusMeter = ref.read(observeAppSettingsUseCaseProvider).searchRange;
    _flingController = AnimationController.unbounded(vsync: this)
      ..addListener(_onFlingTick);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _placeListScrollController.dispose();
    _flingController.dispose();
    _sheetController.dispose();
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
    final Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (_) {
      // 端末の位置情報サービスが無効等で取得できない場合は、デフォルトの
      // カメラ位置 (_defaultCameraPosition) にフォールバックさせる。
      return;
    }
    if (!mounted) return;
    setState(() => _currentPosition = position);

    // GoogleMap が initialCameraPosition (デフォルト位置) で先に生成済みの場合、
    // initialCameraPosition を書き換えても地図は移動しないため、
    // 現在地取得完了後に明示的にカメラを移動させる。
    final target = LatLng(position.latitude, position.longitude);
    _mapController?.moveCamera(CameraUpdate.newLatLngZoom(target, 14));
  }

  // -------------------------------------------------------------------------
  // Filter
  // -------------------------------------------------------------------------

  List<Place> _filterPlaces(List<Place> places) {
    var result = places
        .where((place) => !_dismissedPlaceIds.contains(place.placeId))
        .toList();

    if (_searchKeyword.isNotEmpty) {
      final lowerCaseKeyword = _searchKeyword.toLowerCase();
      result = result.where((place) {
        return place.placeName.toLowerCase().contains(lowerCaseKeyword) ||
            place.address.toLowerCase().contains(lowerCaseKeyword);
      }).toList();
    }

    if (_visitedStatuses.length == 1) {
      final wantVisited = _visitedStatuses.contains(VisitStatus.visited);
      result = result.where((place) => place.isVisited == wantVisited).toList();
    }

    if (_category.isNotEmpty) {
      final categoryKeywords = _category
          .toLowerCase()
          .split(RegExp(r'[\s　]+'))
          .where((keyword) => keyword.isNotEmpty);
      result = result
          .where(
            (place) => categoryKeywords.every(
              (keyword) => place.category.toLowerCase().contains(keyword),
            ),
          )
          .toList();
    }

    if (_selectedPurposes.isNotEmpty) {
      result = result.where((place) {
        return place.purposes.any((purpose) {
          final icon = PurposeIcon.fromPurposeName(purpose.purposeName);
          return icon != null && _selectedPurposes.contains(icon);
        });
      }).toList();
    }

    if (_radiusEnabled && _mapCenter != null) {
      result = result.where((place) {
        final distance = Geolocator.distanceBetween(
          _mapCenter!.latitude,
          _mapCenter!.longitude,
          place.latitude,
          place.longitude,
        );
        return distance <= _radiusMeter;
      }).toList();
    }

    final itemsPerPage = _selectedItemsPerPage;
    if (itemsPerPage != null && result.length > itemsPerPage) {
      result = result.take(itemsPerPage).toList();
    }

    return result;
  }

  /// 訪問状態・カテゴリ・目的のいずれかが絞り込まれているかどうか。
  /// フィルターボタンの見た目切り替えに使用する。
  bool get _isFilterActive =>
      _visitedStatuses.length == 1 ||
      _category.isNotEmpty ||
      _selectedPurposes.isNotEmpty;

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
    if (!_radiusEnabled || _mapCenter == null) return {};
    return {
      Circle(
        circleId: const CircleId('radius_overlay'),
        center: _mapCenter!,
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
  // Sheet sizing (drag handle + inertia)
  // -------------------------------------------------------------------------

  /// [_headerKey] でラップした DragHandle + 検索欄 + 半径フィルターバーの
  /// 実際の描画高さを測定する。レイアウト確定後 (postFrameCallback) に呼び出す。
  void _measureHeaderHeight() {
    final renderObject = _headerKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final height = renderObject.size.height;
      if (mounted && _headerHeight != height) {
        setState(() => _headerHeight = height);
      }
    }
  }

  /// [containerHeight] (DraggableScrollableSheet が配置される Stack の高さ) から
  /// minChildSize / maxChildSize / initialChildSize を計算してフィールドへ反映する。
  ///
  /// - 最低の高さ: DragHandle + 検索欄 + 半径フィルターバー + セル2行分
  ///   ([_headerHeight] が未計測の間は前回値を維持する)
  /// - 最大の高さ: 画面全体の高さ (MediaQuery) の3分の2
  ///
  /// DraggableScrollableSheet は minChildSize <= initialChildSize <=
  /// maxChildSize を毎回のビルドで検証するため、_initialChildSize は固定せず
  /// 都度クランプし直す。
  void _updateChildSizeBounds(double containerHeight) {
    if (containerHeight <= 0) return;
    _sheetContainerHeight = containerHeight;

    final screenHeight = MediaQuery.of(context).size.height;
    _maxChildSize = ((screenHeight * 2 / 3) / containerHeight).clamp(0.1, 1.0);

    final headerHeight = _headerHeight;
    if (headerHeight != null) {
      final minPixelHeight = headerHeight + _listItemHeight * 2;
      _minChildSize = (minPixelHeight / containerHeight).clamp(
        0.05,
        _maxChildSize,
      );
    } else {
      _minChildSize = _minChildSize.clamp(0.05, _maxChildSize);
    }

    _initialChildSize = 0.4.clamp(_minChildSize, _maxChildSize);
  }

  void _onFlingTick() {
    if (!_sheetController.isAttached) return;
    final value = _flingController.value;
    if (value <= _minChildSize) {
      _sheetController.jumpTo(_minChildSize);
      _flingController.stop();
      return;
    }
    if (value >= _maxChildSize) {
      _sheetController.jumpTo(_maxChildSize);
      _flingController.stop();
      return;
    }
    _sheetController.jumpTo(value);
  }

  void _onHandleDragStart(DragStartDetails details) {
    _flingController.stop();
  }

  void _onHandleDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached || _sheetContainerHeight <= 0) return;
    final deltaFraction = details.primaryDelta! / _sheetContainerHeight;
    final newSize = (_sheetController.size - deltaFraction).clamp(
      _minChildSize,
      _maxChildSize,
    );
    _sheetController.jumpTo(newSize);
  }

  /// GoogleMap のパン操作と同様に、指を離した速度から摩擦のシミュレーション
  /// ([FrictionSimulation]) を作り、慣性で childSize を収束させる。
  void _onHandleDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached || _sheetContainerHeight <= 0) return;
    final velocityFraction =
        -details.velocity.pixelsPerSecond.dy / _sheetContainerHeight;
    final simulation = FrictionSimulation(
      0.135,
      _sheetController.size,
      velocityFraction,
    );
    _flingController.animateWith(simulation);
  }

  // -------------------------------------------------------------------------
  // List helpers
  // -------------------------------------------------------------------------

  void _scrollToIndex(int index) {
    final controller = _placeListScrollController;
    if (!controller.hasClients) return;
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

  Future<void> _showFilterDialog() async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder: (dialogContext) => FilterDialog(
        itemsPerPageOptions: _itemsPerPageOptions,
        initialItemsPerPage: _selectedItemsPerPage,
        defaultItemsPerPage: _defaultItemsPerPage,
        initialVisitedStatuses: _visitedStatuses,
        initialCategory: _category,
        initialSelectedPurposes: _selectedPurposes,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedItemsPerPage = result.itemsPerPage;
      _visitedStatuses = result.visitStatuses;
      _category = result.category;
      _selectedPurposes = result.purposes;
    });
  }

  Future<bool> _confirmDeletePlace() async {
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: l10n.deleteConfirmTitle,
        message: l10n.deleteConfirmMessage,
        actions: [
          AppDialogAction(
            label: l10n.cancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppDialogAction(
            label: l10n.delete,
            actionStyle: AppDialogActionStyle.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// 削除ボタン押下時のハンドラ。
  ///
  /// 確認ダイアログで削除が確定した場合、実際の削除処理を完了させてから
  /// [Slidable] のセルをスライド + 縮小アニメーションで消す。
  ///
  /// onDismissed が発火した時点で placeId を [_dismissedPlaceIds] へ追加し、
  /// 即座に一覧から除外する。ref.invalidate による再取得は非同期で、完了する
  /// までは直前のリストが表示され続けるため、これを待ってから除外すると
  /// "A dismissed Slidable widget is still part of the tree." エラーになる。
  Future<void> _onTapDeleteAction(
    BuildContext actionContext,
    String placeId,
  ) async {
    final controller = Slidable.of(actionContext);
    final confirmed = await _confirmDeletePlace();
    if (!confirmed || !mounted) return;

    await ref.read(deletePlaceUseCaseProvider.notifier).execute(placeId);
    if (!mounted) return;

    // 削除対象が選択中だった場合は選択を解除する (spec 5.2.4)
    if (ref.read(selectedPlaceStateProvider) == placeId) {
      ref.read(selectedPlaceStateProvider.notifier).select(null);
    }

    controller?.dismiss(
      ResizeRequest(const Duration(milliseconds: 300), () {
        setState(() => _dismissedPlaceIds.add(placeId));
        ref.invalidate(getPlaceListUseCaseProvider);
      }),
      duration: const Duration(milliseconds: 300),
    );
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
            onPressed: () async {
              final imported = await context.push('/settings');
              if (mounted && imported == true) {
                ref.invalidate(getPlaceListUseCaseProvider);
              }
            },
          ),
        ],
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.fetchError(error))),
        data: (places) => LayoutBuilder(
          builder: (context, constraints) =>
              _buildBody(places, selectedId, constraints.maxHeight),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await context.push('/place/new');
          if (mounted && saved == true) {
            ref.invalidate(getPlaceListUseCaseProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    List<Place> places,
    String? selectedId,
    double containerHeight,
  ) {
    // 実際の削除が反映され、一覧から取得できなくなった placeId は
    // _dismissedPlaceIds に残しておく理由がないので取り除く。
    final currentPlaceIds = places.map((place) => place.placeId).toSet();
    _dismissedPlaceIds.removeWhere((id) => !currentPlaceIds.contains(id));

    final filteredPlaces = _filterPlaces(places);
    _lastFilteredPlaces = filteredPlaces;

    _updateChildSizeBounds(containerHeight);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeaderHeight());

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

    // データリストが最小の高さのときの View 上端 + 角丸半径分だけ下を
    // GoogleMap の下端とする。これより下は最小時のシートに隠れるため描画不要。
    final mapHeight =
        (containerHeight - _minChildSize * containerHeight + _sheetCornerRadius)
            .clamp(0.0, containerHeight);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeight,
          child: GoogleMap(
            initialCameraPosition: initialCamera,
            markers: _buildMarkers(filteredPlaces, selectedId),
            circles: _buildCircles(),
            myLocationEnabled: _showCurrentLocation && _currentPosition != null,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() => _mapCenter = initialCamera.target);

              // initialCameraPosition は地図生成時にしか反映されないため、
              // 生成完了時点で既に現在地を取得済みなら明示的にカメラを合わせる。
              final currentPosition = _currentPosition;
              if (currentPosition != null) {
                controller.moveCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      currentPosition.latitude,
                      currentPosition.longitude,
                    ),
                    14,
                  ),
                );
              }
            },
            onCameraMove: (position) {
              setState(() => _mapCenter = position.target);
            },
            onTap: (_) {
              ref.read(selectedPlaceStateProvider.notifier).select(null);
            },
            onLongPress: (latLng) async {
              final saved = await context.push(
                '/place/new',
                extra: {
                  'latitude': latLng.latitude,
                  'longitude': latLng.longitude,
                },
              );
              if (mounted && saved == true) {
                ref.invalidate(getPlaceListUseCaseProvider);
              }
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeight,
          child: const IgnorePointer(
            child: Center(child: MapCenterCrosshair()),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeight,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RoundMapButton(
                    heroTag: 'toggleCurrentLocationButton',
                    onPressed: () => setState(
                      () => _showCurrentLocation = !_showCurrentLocation,
                    ),
                    icon: _showCurrentLocation
                        ? Icons.gps_fixed_outlined
                        : Icons.gps_off_outlined,
                  ),
                  const SizedBox(height: 10),
                  RoundMapButton(
                    heroTag: 'moveToCurrentLocationButton',
                    onPressed: _currentPosition == null
                        ? null
                        : () => _mapController?.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                            ),
                          ),
                    icon: Icons.near_me,
                  ),
                ],
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _initialChildSize,
          minChildSize: _minChildSize,
          maxChildSize: _maxChildSize,
          builder: (sheetContext, sheetScrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_sheetCornerRadius),
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
                  Column(
                    key: _headerKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: _onHandleDragStart,
                        onVerticalDragUpdate: _onHandleDragUpdate,
                        onVerticalDragEnd: _onHandleDragEnd,
                        child: const DragHandle(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: HomeSearchBar(
                              controller: _searchController,
                              keyword: _searchKeyword,
                              onChanged: (keyword) =>
                                  setState(() => _searchKeyword = keyword),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _isFilterActive
                                ? IconButton.filled(
                                    style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    icon: const Icon(Icons.tune),
                                    onPressed: _showFilterDialog,
                                  )
                                : IconButton.outlined(
                                    style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    icon: const Icon(Icons.tune),
                                    onPressed: _showFilterDialog,
                                  ),
                          ),
                        ],
                      ),
                      RadiusFilterBar(
                        radiusMeter: _radiusMeter,
                        onRadiusChanged: (radius) {
                          setState(() => _radiusMeter = radius);
                          ref
                              .read(
                                observeAppSettingsUseCaseProvider.notifier,
                              )
                              .updateSearchRange(radius);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, listConstraints) => _buildPlaceList(
                        filteredPlaces,
                        selectedId,
                        _placeListScrollController,
                        listConstraints.maxHeight,
                      ),
                    ),
                  ),
                  // DraggableScrollableSheet 内部の scrollController は、
                  // builder が返すツリーのどこかで実際に使われていないと
                  // DraggableScrollableController.jumpTo/size が
                  // 「アタッチされていない」例外を起こす。
                  // しかし可視のリストにこれを使うと、リストが先頭までスクロール
                  // された状態でのスワイプがシートの高さ調整として扱われてしまい、
                  // 要件(リストのスワイプでは高さ調整しない)に反する。
                  // そのため画面には表示されない Offstage な ScrollView にのみ
                  // このコントローラーを繋ぎ、アタッチ状態だけを満たす。
                  Offstage(
                    child: SingleChildScrollView(
                      controller: sheetScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: const SizedBox.shrink(),
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
    double availableHeight,
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

    // 表示領域の余白が FAB 分 (_fabReservedHeight) に満たない場合のみ、
    // その不足分だけ下部にスクロール余地を追加する。
    // contentHeight が表示領域より大きい場合、余白の計算上は表示領域いっぱいに
    // 埋まっているものとして扱う (これ以上はみ出した分を余白計算に含めない)。
    final contentHeight = _listItemHeight * places.length;
    final clampedContentHeight = contentHeight > availableHeight
        ? availableHeight
        : contentHeight;
    final margin = availableHeight - clampedContentHeight;
    final adjustedMargin = margin < _fabReservedHeight
        ? _fabReservedHeight
        : margin;
    final bottomPadding = adjustedMargin - margin;

    return ListView.builder(
      controller: scrollController,
      itemCount: places.length,
      itemExtent: _listItemHeight,
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemBuilder: (itemContext, index) {
        final place = places[index];
        final isSelected = place.placeId == selectedId;

        return Container(
          decoration: BoxDecoration(
            border: index == 0
                ? null
                : Border(
                    top: BorderSide(color: Theme.of(itemContext).dividerColor),
                  ),
          ),
          child: PlaceCell(
            place: place,
            isSelected: isSelected,
            onTap: () =>
                ref.read(selectedPlaceStateProvider.notifier).select(place.placeId),
            onCopyUrl: () => _copyUrl(place),
            onDeleteRequested: (actionContext) =>
                _onTapDeleteAction(actionContext, place.placeId),
            onDetailTap: () async {
              final saved = await context.push('/place/${place.placeId}');
              if (mounted && saved == true) {
                ref.invalidate(getPlaceListUseCaseProvider);
              }
            },
          ),
        );
      },
    );
  }
}
