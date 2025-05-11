import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/viewmodel/provider/home_view_model_notifier_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'setting_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      MaterialPageRoute(builder: (context) => SettingView())
                  )
                }),
              ],
            ),
            body: ref.watch(homeViewModelNotifierProvider).when(
                data: (homeModel) =>
                    ListView.builder(
                        itemCount: homeModel.favoritePlaces.length,
                        itemBuilder: (_, index) {
                          final favoritePlace = homeModel.favoritePlaces[index];
                          return favoritePlaceList(favoritePlace);
                        }),
                error: (error, _) => const Center(child: Text('通信エラー')),
                loading: () =>
                const Center(child: CircularProgressIndicator()))));
  }

  Widget favoritePlaceList(FavoritePlaceEntity favoritePlaceEntity) {
    late GoogleMapController mapController;

    final LatLng _center = const LatLng(45.521563, -122.677433);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              ),
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
      await launchUrl(uri);
    } else {
      debugPrint('Cloud not launch: $url');
    }
  }
}
