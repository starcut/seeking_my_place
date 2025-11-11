import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:seeking_my_place/Common/Enum/favorite_menu_item.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:seeking_my_place/api/controller/database_manager.dart';
import 'package:seeking_my_place/provider/home_provider.dart';
import 'package:seeking_my_place/provider/place_register_provider.dart';
import 'package:seeking_my_place/view/place_register_view.dart';
import 'package:seeking_my_place/view/setting_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  final mapControllerCompleter = Completer<GoogleMapController>();
  Future<void> onMapCreated(GoogleMapController controller) async {
    mapControllerCompleter.complete(controller);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ナビゲーションバーのボタン
    final settingButton = IconButton(icon: const Icon(Icons.settings),
        onPressed: () async {
      var result = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SettingView();
          }));
      await _updateSettingData();
    });

    final registerButton = IconButton(icon: const Icon(Icons.add_location_alt_outlined),
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                // 親の container を明示的に取得する（←これが重要！）
                final parentContainer = ProviderScope.containerOf(context, listen: false);

                return UncontrolledProviderScope(
                  container: ProviderContainer(
                    parent: parentContainer, // ← 親スコープを明示的に継承！
                    overrides: [
                      urlTextFieldProvider.overrideWith(
                              (ref) => TextFieldNotifier("")
                      ),
                      placeNameTextFieldProvider.overrideWith(
                              (ref) => TextFieldNotifier("")
                      ),
                      addressTextFieldProvider.overrideWith(
                              (ref) => TextFieldNotifier("")
                      ),
                      categoryTextFieldProvider.overrideWith(
                              (ref) => TextFieldNotifier("")
                      ),
                      purposeTextFieldProvider.overrideWith(
                              (ref) => PurposeNotifier(PurposeEntity(id: 1, purposeName: "未設定"))
                      ),
                      isVisitedTextFieldProvider.overrideWith(
                            (ref) => CheckBoxNotifier(false),
                      ),
                    ],
                  ),
                  child: PlaceRegisterView(),
                );
              },
            ),
          );
          await _updateSettingData();
        }
    );

    final importButton = IconButton(icon: const Icon(Icons.download),
        onPressed: () async {
          await _importDatabase();
        });

    final exportButton = IconButton(icon: const Icon(Icons.upload),
        onPressed: () async {
      await shareFile();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await moveCamera();
      await _updateSettingData();
    });

    return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(''),
              actions: [
                settingButton,
                registerButton,
                importButton,
                exportButton
              ],
            ),
            body: Consumer(
              builder: (context, ref, child) {
                return Column(children: [
                  settingView(ref),
                  if (ref.watch(googleMapDisplayStateNotifierProvider)) ... [
                    googleMapView(),
                  ],
                  favoriteListView()
                ],);
              }
            )
        );
  }

  Future<void> moveCamera() async {
    await ref.read(locationSearchStateNotifierProvider.notifier).getCurrentPosition();
    var currentLocation = ref.watch(locationSearchStateNotifierProvider);
    final mapController = await mapControllerCompleter.future;
    final latitude = currentLocation?.latitude;
    final longitude = currentLocation?.longitude;
    if (latitude == null || longitude == null) {
      return;
    }
    await mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 11.0,
        ),
      ),
    );
  }

  Widget settingView(WidgetRef ref) {
    final updateButton = IconButton(icon: const Icon(Icons.refresh),
        onPressed: () async {
          await _updateSettingData();
    });

    return Consumer(
      builder: (context, ref, _) {
        final settingData = ref.watch(settingStateNotifierProvider);
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("表示可能件数： ${settingData.listCount}件"),
                Text("表示可能範囲： ${settingData.range}km")
              ],
            ),
            const Spacer(),
            googleMapSwitch(),
            updateButton
          ],
        );
      },
    );
  }

  Widget googleMapView() {
    Set<Marker> markers = ref.watch(markerListStateNotifierProvider);
    var currentLocation = ref.read(locationSearchStateNotifierProvider);
    var range = ref.read(settingStateNotifierProvider).range;
    print("現在表示位置：${currentLocation?.longitude} ${currentLocation?.latitude}");

    if (currentLocation == null) {
      return const Spacer();
    }

    GoogleMap currentMarker = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: currentLocation,
        zoom: 11.0,
      ),
      markers: markers,
      circles: {
        Circle(
          circleId: const CircleId('circle_1'),
          center: currentLocation,
          radius: range * 1000,
          fillColor: Colors.red.withAlpha(30),
          strokeWidth: 2,
          strokeColor: Colors.red
        ),
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer(),),
      },
    );

    return GestureDetector(child: Container(
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                child: currentMarker
            ),
          ],
        )),
    );
  }

  double? distanceFromCurrentLocation(LatLng? currentLocation, double? longitude, double? latitude, String name) {
    double? distance;
    if (longitude == null || latitude == null || currentLocation == null) {
      return distance;
    }

    final currentLatitudeRad = currentLocation.latitude * pi / 180.0;
    final currentLongitudeRad = currentLocation.longitude * pi / 180.0;
    final latitudeRad = latitude * pi / 180.0;
    final longitudeRad = longitude * pi / 180.0;

    final diffLatitude = latitudeRad - currentLatitudeRad;
    final diffLongitude = longitudeRad - currentLongitudeRad;

    distance = 2.0 * 6371
        * asin(sqrt(
            sin(diffLatitude / 2.0) * sin(diffLatitude / 2.0)
                + cos(currentLatitudeRad) * cos(latitudeRad)
                * sin(diffLongitude / 2.0) * sin(diffLongitude / 2.0)
        ));
    return distance;
  }

  Widget googleMapSwitch() {
    bool isDisplay = ref.watch(googleMapDisplayStateNotifierProvider);
    return Row(
      children: [
        const Text("GoogleMap\n表示切替", textAlign: TextAlign.center,),
        Switch(value: isDisplay,
            onChanged: (value){
          ref.read(googleMapDisplayStateNotifierProvider.notifier).switchDisplayGoogleMap(value);
        }),
      ],
    );
  }

  Widget favoriteListView() {
    var favorite = ref.watch(favoritePlaceListStateNotifierProvider);

    if (favorite.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
        ),
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 50,
        child: const Text("登録なし"),
      );
    }

    LatLng? currentLocation = ref.watch(locationSearchStateNotifierProvider);
    // 取得したリストをListView.builderに渡す
    return Expanded(
        child: RefreshIndicator(
            onRefresh: () async {
              await _updateSettingData();
            },
            child: ListView.builder(
                itemCount: favorite.length,
                itemBuilder: (context, index) {
                  final favoritePlace = favorite[index];
                  double? distance = distanceFromCurrentLocation(currentLocation, favoritePlace.longitude, favoritePlace.latitude, favoritePlace.placeName);
                  String distanceString = "";
                  if (distance != null) {
                    if (distance < 1) {
                      distance = distance * 1000;
                      distanceString = "${distance.toStringAsFixed(0)}m";
                    }
                    distanceString = "${distance.toStringAsFixed(1)}km";
                  }
                  return Container(
                          padding: const EdgeInsets.all(0),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
                          ),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 86,
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (favoritePlace.isVisited) ... [
                                            Icon(Icons.check_circle, size: 18, color: Colors.green)
                                          ],
                                          Text("${favoritePlace.placeName} ",
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${favoritePlace.category} ",
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                              "${(favoritePlace.purpose == '未設定') ? '' : favoritePlace.purpose}",
                                              style: const TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                      ),
                                      Text("$distanceString ${favoritePlace.address}")
                                    ],
                                  )
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String selected) {
                                  switch (FavoriteMenuItem.getFavoriteMenuItemFromString(selected)) {
                                    case FavoriteMenuItem.edit:
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProviderScope(
                                            overrides: [
                                              urlTextFieldProvider.overrideWith(
                                                      (ref) => TextFieldNotifier(favoritePlace.url)
                                              ),
                                              placeNameTextFieldProvider.overrideWith(
                                                      (ref) => TextFieldNotifier(favoritePlace.placeName)
                                              ),
                                              addressTextFieldProvider.overrideWith(
                                                      (ref) => TextFieldNotifier(favoritePlace.address)
                                              ),
                                              categoryTextFieldProvider.overrideWith(
                                                      (ref) => TextFieldNotifier(favoritePlace.category)
                                              ),
                                              purposeTextFieldProvider.overrideWith((ref) {
                                                final purposeEntity = (PurposeEntity(id: 0, purposeName: favoritePlace.purpose));
                                                return PurposeNotifier(purposeEntity);
                                              }),
                                              isVisitedTextFieldProvider.overrideWith(
                                                    (ref) => CheckBoxNotifier(favoritePlace.isVisited),
                                              ),
                                            ],
                                            child: PlaceRegisterView(),
                                          ),
                                        ),
                                      );
                                      break;
                                    case FavoriteMenuItem.copyUrl:
                                      final copyUrl = ClipboardData(text: favoritePlace.url);
                                      Clipboard.setData(copyUrl);
                                      break;
                                    case FavoriteMenuItem.openBrowser:
                                      _openWebPage(favoritePlace.url);
                                      break;
                                    case FavoriteMenuItem.delete:
                                      int? deleteId = favoritePlace.id;
                                      if (deleteId == null) {
                                        return;
                                      }
                                      ref.read(favoritePlaceListStateNotifierProvider.notifier).deleteFavoritePlace(deleteId);
                                      _updateSettingData();
                                      break;
                                    default:
                                      print("不明なメニュー");
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  var menuItem = FavoriteMenuItem.getUseableString();
                                  return menuItem.map((String menuString) {
                                    var text = Text(menuString);
                                    if (menuString == FavoriteMenuItem.delete.name) {
                                      text = Text(menuString,
                                      style: const TextStyle(color: Colors.red));
                                    }
                                    return PopupMenuItem(
                                      value: menuString,
                                      child: text,
                                    );
                                  }).toList();
                                },
                              )
                            ],
                          )
                      // )
                  );
                }
            )
        )
    );
  }

  Future _updateSettingData() async {
    await ref.read(settingStateNotifierProvider.notifier).loadSettingData();
    await ref.read(favoritePlaceListStateNotifierProvider.notifier).getFavoritePlace();
    await ref.read(locationSearchStateNotifierProvider.notifier).getCurrentPosition();
    if (ref.watch(googleMapDisplayStateNotifierProvider)) {
      await ref.read(markerListStateNotifierProvider.notifier).getMarkerList();
      await moveCamera();
    }
  }

  Future _openWebPage(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await http.get(uri);
      await launchUrl(uri);
    } else {
      debugPrint('Cloud not launch: $url');
    }
  }

  Future shareFile() async {
    String filePath = await createFile();
    SharePlus.instance.share(ShareParams(title: "ファイル共有", files: [XFile(filePath)]));
  }

  Future<String> createFile() async {
    List<List<dynamic>> data = [
      [
        DatabaseManager.shared.columnPlaceListId,
        DatabaseManager.shared.columnPlaceListPlaceName,
        DatabaseManager.shared.columnPlaceListAddress,
        DatabaseManager.shared.columnPlaceListLatitude,
        DatabaseManager.shared.columnPlaceListLongitude,
        DatabaseManager.shared.columnPlaceListUrl,
        DatabaseManager.shared.columnPlaceListCategory,
        DatabaseManager.shared.columnPlaceListPurpose,
        DatabaseManager.shared.columnPlaceListIsVisited,
        DatabaseManager.shared.columnPlaceListRegisterAt,
        DatabaseManager.shared.columnPlaceListUpdateAt
      ]
    ];
    var placeList = await DatabaseManager.shared.selectAllPlaces();

    for (var place in placeList) {
      var rowData = [
        place.id,
        place.placeName,
        place.address,
        place.latitude,
        place.longitude,
        place.url,
        place.category,
        place.purpose,
        place.isVisited,
        place.registerAt,
        place.updateAt,
      ];
      data.add(rowData);
    }

    String csvData = const ListToCsvConverter().convert(data);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/favorite_place_list.csv';

    final file = File(path);
    await file.writeAsString(csvData);

    return path;
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  // データベースファイルをインポートする関数
  Future<void> _importDatabase() async {
    try {
      // FilePickerを使用してファイル選択ダイアログを表示
      // FileType.anyを指定することで、すべての種類のファイルを選択可能にします
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      // ファイルが選択された場合の処理
      if (result != null && result.files.single.path != null) {
        // 選択されたファイルのパスからFileオブジェクトを作成
        final file = File(result.files.single.path!);

        // データベースインポート処理を実行
        await DatabaseManager.shared.importDatabaseFromCsv(file);

        // Riverpodのプロバイダーを更新して、UIを最新の状態に反映
        await ref.read(favoritePlaceListStateNotifierProvider.notifier).getFavoritePlace();
        await ref.read(markerListStateNotifierProvider.notifier).getMarkerList();
        // 成功メッセージをスナックバーで表示
        SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.green,
          content: Text('データベースをインポートしました！'),
        );
        _scaffoldKey.currentState?.showSnackBar(snackBar);
      }
    } catch (e) {
      // エラーが発生した場合はエラーメッセージを表示
      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.green,
        content: Text('インポートに失敗しました！'),
      );
      _scaffoldKey.currentState?.showSnackBar(snackBar);
    }
  }
}
