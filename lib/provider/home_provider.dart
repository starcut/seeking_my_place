import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seeking_my_place/api/controller/database_manager.dart';

import 'package:seeking_my_place/api/controller/location_manager.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingData {
  final int listCount;
  final double range;

  SettingData({
    required this.listCount,
    required this.range
  });
}

final settingStateNotifierProvider = StateNotifierProvider<SettingStateNotifierProvider, SettingData>((ref) {
  return SettingStateNotifierProvider();
});

class SettingStateNotifierProvider extends StateNotifier<SettingData> {
  SettingStateNotifierProvider() : super(SettingData(listCount: 10, range: 10.0)) {
    loadSettingData();
  }

  Future<SettingData> loadSettingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final listCount = prefs.getInt('display_count') ?? 10;
    final range = prefs.getDouble('display_range') ?? 10.0;
    state = SettingData(listCount: listCount, range: range);
    return state;
  }
}

final googleMapDisplayStateNotifierProvider = StateNotifierProvider<GoogleMapDisplayStateNotifierProvider, bool>((ref) {
  return GoogleMapDisplayStateNotifierProvider();
});

class GoogleMapDisplayStateNotifierProvider extends StateNotifier<bool> {
  GoogleMapDisplayStateNotifierProvider() : super(true) {
    loadDisplayGoogleMap();
  }

  Future loadDisplayGoogleMap() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('google_map_display') ?? false;
  }

  void switchDisplayGoogleMap(bool isDisplay) async {
    state = isDisplay;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('google_map_display', state);
  }
}

final locationSearchStateNotifierProvider =
StateNotifierProvider<LocationProvider, LatLng?>((ref) {
  return LocationProvider();
});

class LocationProvider extends StateNotifier<LatLng?> {
  LocationProvider() : super(null) {
    loadCurrentPosition();
  }

  Future<LatLng> loadCurrentPosition() async {
    await LocationManager.shared.request();
    var position = await LocationManager.shared.determinePosition();
    return LatLng(position.latitude, position.longitude);
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
      final favoriteList = await DatabaseManager.shared.selectAllPlaces();
      final prefs = await SharedPreferences.getInstance();
      int countList = prefs.getInt('display_count') ?? 10;
      double range = prefs.getDouble('display_range') ?? 10.0;

      await LocationManager.shared.request();
      var position = await LocationManager.shared.determinePosition();
      var currentLocation = LatLng(position.latitude, position.longitude);

      state = [];
      for (var favoritePlace in favoriteList) {
        double? distance = distanceFromCurrentLocation(currentLocation, favoritePlace.longitude, favoritePlace.latitude, favoritePlace.placeName);
        if (distance == null) {
          continue;
        }
        if (distance <= range) {
          state.add(favoritePlace);
          if (state.length >= countList) {
            return;
          }
        }
      }
    } on Exception catch (exception) {
      throw Exception(exception);
    }
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
    var favoritePlaces = <FavoritePlaceEntity>[];
    List<FavoritePlaceEntity> filteredFavoritePlaces = [];
    try {
      favoritePlaces = await DatabaseManager.shared.selectAllPlaces();

      final prefs = await SharedPreferences.getInstance();
      int countList = prefs.getInt('display_count') ?? 10;
      double range = prefs.getDouble('display_range') ?? 10.0;

      await LocationManager.shared.request();
      var position = await LocationManager.shared.determinePosition();
      var currentLocation = LatLng(position.latitude, position.longitude);

      for (var favoritePlace in favoritePlaces) {
        double? distance = distanceFromCurrentLocation(currentLocation, favoritePlace.longitude, favoritePlace.latitude, favoritePlace.placeName);
        if (distance == null) {
          continue;
        }
        if (distance <= range) {
          filteredFavoritePlaces.add(favoritePlace);
          if (filteredFavoritePlaces.length >= countList) {
            break;
          }
        }
      }

    } on Exception catch (exception) {
      throw Exception(exception);
    }

    state = Set();

    for (var favoritePlace in filteredFavoritePlaces) {
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
}