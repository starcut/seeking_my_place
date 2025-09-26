import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:seeking_my_place/view/place_register_view.dart';
import 'package:seeking_my_place/view/setting_view.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/view_model/home_view_model.dart';

class HomeView extends ConsumerWidget {
  HomeView({super.key});

  late List<PurposeEntity> purposeList;

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
        onPressed: () async => {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => PlaceRegisterView()))
    });

    final favoriteListView = ref.watch(homeViewModelNotifierProvider).when(data: (favoriteList) {
      if(favoriteList.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: const Text("登録なし"),
        );
      }

      // 取得したリストをListView.builderに渡す
      return Expanded(
          child: ListView.builder(
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            final favorite = favoriteList[index];
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
                    SlidableAction(onPressed: (_) {
                      int? deleteId = favorite.id;
                      if (deleteId == null) {
                        return;
                      }
                      ref.read(deleteFavoritePlaceFamily(deleteId));
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
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${favorite.placeName} ${favorite.category} ${favorite.purpose}" , style: const TextStyle(fontWeight: FontWeight.bold),),
                        Text(favorite.address)
                    ],)
              )
            );
          }));
      },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator())
    );

    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.grey),
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(''),
              actions: [
                settingButton,
                registerButton,
              ],
            ),
            body: Column(children: [
              googleMapView(context, ref),
              favoriteListView
            ],)
        )
    );
  }

  Widget googleMapView(BuildContext context, WidgetRef ref) {
    late GoogleMapController mapController;

    void onMapCreated(GoogleMapController controller) async {
      mapController = controller;
    }
    Set<Marker> markers = ref.watch(homeViewModelMarkerNotifierProvider).when(data: (markers) {
      return markers;
    }, error: (Object error, StackTrace stackTrace) { return {}; }, loading: () { return {}; });
    final googleMapWidget = ref.watch(homeViewModelCurrentLocationNotifierProvider)
        .when(data: (currentLocation) {
      return GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentLocation,
          zoom: 11.0,
        ),
        markers: markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
          ),
        },
      );
    }, error: (error, _) {
      return const Center(child: Text('お気に入りの場所のデータベース読み込みエラー'));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });

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
                child: googleMapWidget
            ),
          ],
        )),
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
      openWebPage(favoritePlaceEntity.url);
    },
    );
  }

  Future openWebPage(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      var response = await http.get(uri);
      await launchUrl(uri);
    } else {
      debugPrint('Cloud not launch: $url');
    }
  }
}
