import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final viewModel =
        ref.read(purposeListStateNotifierProvider.notifier);
    final changeNotifier = ref.watch(changeNotifierProvider);
    // final purposeList = viewModel.getPurposeList();
    // purposeList.then((purposeLists) {
    //   this.purposeList = purposeLists;
    // });

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
                    onPressed: () async => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlaceRegisterView()))
                    }),
              ],
            ),
            body: Column(children: [
              googleMapVIew(context),
              Consumer(builder: (context, ref, _) {
                return ref.watch(homeViewModelNotifierProvider).when(data: (favoritePlaces) {
                  if (favoritePlaces.isEmpty) {
                    return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
                        child: Center(child: Text("お気に入り場所なし"))
                    );
                  }
                  return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.5 - 120,
                      child: CustomScrollView(
                        // TODO: shrinkWrapはtrueだとメモリを食うため要修正
                         shrinkWrap: true,
                         slivers: [
                           SliverList(
                               delegate: SliverChildBuilderDelegate(
                                 childCount: favoritePlaces.length,
                                     (BuildContext context, int index) {
                                   final favoritePlace = favoritePlaces[index];
                                   return favoritePlaceList(context, favoritePlace);
                                   },
                               )
                           ),
                         ]
                      )
                  );
                // return ListView.builder(
                //     shrinkWrap: true,
                //     itemCount: favoritePlaces.length,
                //     itemBuilder: (_, index) {
                //       final favoritePlace = favoritePlaces[index];
                //       return favoritePlaceList(context, favoritePlace);
                //     });
              },
                  error: (error, _) {
                    print("error");
                    return const Center(child: Text('お気に入りの場所のデータベース読み込みエラー'));
                  },
                  loading: () {
                    print("loading");
                    return const Center(child: CircularProgressIndicator());
                  });
            })
            ],
            )
    ));
  }

  Widget googleMapVIew(BuildContext context) {
    late GoogleMapController mapController;

    final LatLng _center = const LatLng(45.521563, -122.677433);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
              border:
              Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
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
            ],
          )),
    );
  }

  Widget favoritePlaceList(BuildContext context, FavoritePlaceEntity favoritePlaceEntity) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
          child: Row(
            children: [
              Text(favoritePlaceEntity.placeName, style: const TextStyle(color: Colors.black, fontSize: 16.0)),
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingView()))
                }),
        ]
          )
      ),
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
