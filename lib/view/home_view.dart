import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:seeking_my_place/view/place_register_view.dart';
import 'package:seeking_my_place/view/setting_view.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/viewmodel/home_view_model.dart';

class HomeView extends ConsumerWidget {
  HomeView({super.key});

  late List<PurposeEntity> purposeList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository =
        ref.read(purposeListStateNotifierProvider.notifier).getPurposeList();
    repository.then((homeModel) {
      purposeList = homeModel.purposeLists;
    });
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.grey),
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text(''),
              actions: [
                IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingView()))
                        }),
                IconButton(
                    icon: const Icon(Icons.add_location_alt_outlined),
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PlaceRegisterView()))
                        }),
              ],
            ),
            body: ref.watch(homeViewModelNotifierProvider).when(
                data: (homeModel) => ListView.builder(
                    itemCount: homeModel.favoritePlaces.length,
                    itemBuilder: (_, index) {
                      final favoritePlace = homeModel.favoritePlaces[index];
                      return favoritePlaceList(context, favoritePlace);
                    }),
                error: (error, _) => const Center(child: Text('通信エラー')),
                loading: () =>
                    const Center(child: CircularProgressIndicator()))));
  }

  Widget favoritePlaceList(
      BuildContext context, FavoritePlaceEntity favoritePlaceEntity) {
    late GoogleMapController mapController;

    final LatLng _center = const LatLng(45.521563, -122.677433);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 300,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  favoritePlaceEntity.placeName,
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ],
          )),
      onTap: () {
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
