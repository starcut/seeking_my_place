import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seeking_my_place/api/controller/database/database_manager.dart';

import 'package:seeking_my_place/api/controller/location/location_manager.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';

final locationSearchStateNotifierProvider =
StateNotifierProvider<LocationProvider, LatLng>((ref) {
  return LocationProvider(const LatLng(0,0));
});

class LocationProvider extends StateNotifier<LatLng> {
  LocationProvider(LatLng state) : super(state) {
    getCurrentPosition();
  }

  Future getCurrentPosition() async {
    await LocationManager.shared.request();
    var position = await LocationManager.shared.determinePosition();
    state = LatLng(position.latitude, position.longitude);
  }
}

final favoritePlaceListStateNotifierProvider =
StateNotifierProvider<FavoritePlaceProvider, List<FavoritePlaceEntity>>((ref) {
  return FavoritePlaceProvider([]);
});

class FavoritePlaceProvider extends StateNotifier<List<FavoritePlaceEntity>> {
  FavoritePlaceProvider(List<FavoritePlaceEntity> state) : super([]) {
    getFavoritePlace();
  }

  Future getFavoritePlace() async {
    try {
      state = await DatabaseManager.shared.selectAllPlaces();
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}

final favoritePlaceListUpdateStateNotifierProvider =
StateNotifierProvider<FavoritePlaceUpdateProvider, void>((ref) {
  return FavoritePlaceUpdateProvider();
});

class FavoritePlaceUpdateProvider extends StateNotifier<void> {
  FavoritePlaceUpdateProvider() : super(0);

  Future deleteFavoritePlace(int id) async {
    try {
      await DatabaseManager.shared.deleterFavoritePlace(id);
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}

final markerListStateNotifierProvider =
StateNotifierProvider<MarkerListProvider, Set<Marker>>((ref) {
  return MarkerListProvider(Set());
});

class MarkerListProvider extends StateNotifier<Set<Marker>> {
  MarkerListProvider(Set<Marker> state) : super(Set()) {
    getMarkerList();
  }

  Future getMarkerList() async {
    state = Set();
    var favoritePlaces = <FavoritePlaceEntity>[];
    try {
      favoritePlaces = await DatabaseManager.shared.selectAllPlaces();
    } on Exception catch (exception) {
      throw Exception(exception);
    }

    for (var favoritePlace in favoritePlaces) {
      double? latitude = favoritePlace.latitude;
      double? longitude = favoritePlace.longitude;
      if (latitude == null || longitude == null) {
        continue;
      }

      var markerColor = BitmapDescriptor.hueRed;
      switch (favoritePlace.purpose) {
        case 0:
          markerColor = BitmapDescriptor.hueRed;
          break;
        default:
          markerColor = BitmapDescriptor.hueYellow;
          break;
      }

      state.add(
          Marker(
            markerId: MarkerId(favoritePlace.id.toString()),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: favoritePlace.placeName),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              markerColor,
            ),
          )
      );
    }
  }
}