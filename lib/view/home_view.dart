import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:seeking_my_place/api/controller/database/database_manager.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/Provider/home_provider.dart';
import 'package:seeking_my_place/view/place_register_view.dart';
import 'package:seeking_my_place/view/setting_view.dart';

class HomeView extends ConsumerWidget {
  HomeView({super.key});

  late List<PurposeEntity> purposeList;
  late List<FavoritePlaceEntity> favoriteList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ナビゲーションバーのボタン
    final settingButton = IconButton(icon: const Icon(Icons.settings),
        onPressed: () => {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SettingView();
          }))
    });

    final registerButton = IconButton(icon: const Icon(Icons.add_location_alt_outlined),
        onPressed: () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => PlaceRegisterView(),)
          );
          if (result) {
            await _updateFavoritePlaceData(ref);
          }
        }
    );

    final importButton = IconButton(icon: const Icon(Icons.download),
        onPressed: () async {
          await _importDatabase(context, ref);
        });

    final exportButton = IconButton(icon: const Icon(Icons.upload),
        onPressed: () async {
      await shareFile();
    });

    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.grey),
        home: Scaffold(
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
                  googleMapView(context, ref),
                  favoriteListView(context, ref)
                ],);
              }
            )
        )
    );
  }

  Widget googleMapView(BuildContext context, WidgetRef ref) {
    late GoogleMapController mapController;

    void onMapCreated(GoogleMapController controller) async {
      mapController = controller;
    }
    Set<Marker> markers = ref.watch(markerListStateNotifierProvider);
    LatLng currentLocation = ref.watch(locationSearchStateNotifierProvider);

    GoogleMap currentMarker = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: currentLocation,
        zoom: 11.0,
      ),
      markers: markers,
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

  double? distanceFromCurrentLocation(LatLng currentLocation, double? longitude, double? latitude, String name) {
    double? distance;
    if (longitude == null || latitude == null) {
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

  Widget favoriteListView(BuildContext context, WidgetRef ref) {
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

    LatLng currentLocation = ref.watch(locationSearchStateNotifierProvider);
    // 取得したリストをListView.builderに渡す
    return Expanded(
        child: RefreshIndicator(
            onRefresh: () async {
              await _updateFavoritePlaceData(ref);
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
                  return Slidable(
                      key: UniqueKey(),
                      startActionPane: ActionPane(motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          children: [
                            SlidableAction(onPressed: (_) {
                              print("お気に入りデータピン留めする");
                            },
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.push_pin)
                          ]
                      ),
                      endActionPane: ActionPane(motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          children: [
                            SlidableAction(onPressed: (_) async {
                              int? deleteId = favoritePlace.id;
                              if (deleteId == null) {
                                return;
                              }
                              _updateFavoritePlaceData(ref);
                            },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete)
                          ]
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(0),
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
                          ),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 65,
                          child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${favoritePlace.placeName} ${favoritePlace.category} ${favoritePlace.purpose}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              Text("${distanceString} ${favoritePlace.address}")
                            ],)
                      )
                  );
                }
            )
        )
    );
  }

  Widget favoritePlaceList(BuildContext context, FavoritePlaceEntity favoritePlaceEntity) {
    final openWebButton = IconButton(icon: const Icon(Icons.language),
        onPressed: () =>
        {
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) => SettingView()))
        }
    );

    return GestureDetector(child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
        ),
        child: Row(children: [
          Text(favoritePlaceEntity.placeName, style: const TextStyle(color: Colors.black, fontSize: 16.0)),
          openWebButton,
        ]
        )
    ), onTap: () {
      _openWebPage(favoritePlaceEntity.url);
    },
    );
  }

  Future _updateFavoritePlaceData(WidgetRef ref) async {
    await ref.read(favoritePlaceListStateNotifierProvider.notifier).getFavoritePlace();
    await ref.read(locationSearchStateNotifierProvider.notifier).getCurrentPosition();
    await ref.read(markerListStateNotifierProvider.notifier).getMarkerList();
  }

  Future _openWebPage(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      var response = await http.get(uri);
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
        DatabaseManager.shared.columnPlaceListPurpose,
        DatabaseManager.shared.columnPlaceListCategory,
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
        place.purpose,
        place.category,
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
  Future<void> _importDatabase(BuildContext context, WidgetRef ref) async {
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
        print("_scaffoldKey: ${_scaffoldKey.currentState}");
        _scaffoldKey.currentState?.showSnackBar(snackBar);
      }
    } catch (e) {
      // エラーが発生した場合はエラーメッセージを表示

      SnackBar snackBar = const SnackBar(
        backgroundColor: Colors.green,
        content: Text('インポートに失敗しました！'),
      );
      print("_scaffoldKey: ${_scaffoldKey.currentState}");
      _scaffoldKey.currentState?.showSnackBar(snackBar);
    }
  }
}
