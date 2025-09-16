import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seeking_my_place/api/controller/location/location_manager.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:seeking_my_place/repository/home_repository.dart';

final homeViewModelNotifierProvider = FutureProvider<List<FavoritePlaceEntity>>((ref) async {
  print("start homeViewModelNotifierProvider");
  final viewModel = HomeViewModel(repository: ref.read(homeRepositoryProvider));
  await viewModel.getFavoritePlace();
  return viewModel.favoritePlaces;
});

final homeViewModelCurrentLocationNotifierProvider = FutureProvider<LatLng>((ref) async {
  print("start homeViewModelCurrentLocationNotifierProvider");
  final viewModel = HomeViewModel(repository: ref.read(homeRepositoryProvider));
  return await viewModel.getCurrentPosition();
});

final deleteFavoritePlaceFamily = FutureProvider.family<void, int>((ref, id) async {
  final viewModel = HomeViewModel(repository: ref.read(homeRepositoryProvider));
  viewModel.deleteFavoritePlace(id);
});

final homeViewModelMarkerNotifierProvider = FutureProvider<Set<Marker>>((ref) async {
  print("start homeViewModelNotifierProvider");
  final viewModel = HomeViewModel(repository: ref.read(homeRepositoryProvider));
  await viewModel.getFavoritePlace();
  return await viewModel.getMarkerList();
});

final purposeListStateNotifierProvider =
    StateNotifierProvider<Purpose, int>((ref) {
  return Purpose(ref);
});

class Purpose extends StateNotifier<int> {
  Purpose(this.ref) : super(0);

  final Ref ref;

  Future<List<PurposeEntity>> getPurposeList() async {
    debugPrint("getPurposeList");
    final repository = ref.read(homeRepositoryProvider);
    final purposeList = await repository.getPurposeListDataRepository();
    return purposeList;
  }

  Future<LatLng> getCurrentPosition() async {
    await LocationManager.shared.request();
    var position = await LocationManager.shared.determinePosition();
    return LatLng(position.latitude, position.longitude);
  }
}

class HomeViewModel {
  final HomeRepository repository;

  HomeViewModel({required this.repository});

  late List<FavoritePlaceEntity> _favoritePlaces;
  List<FavoritePlaceEntity> get favoritePlaces => _favoritePlaces;

  late List<PurposeEntity> _purposeList;
  List<PurposeEntity> get purposeList => _purposeList;

  bool isLoading = false;

  Future getFavoritePlace() async {
    try {
      print("start viewmodel getFavoritePlace");
      _favoritePlaces = await repository.getFavoritePlaceData();
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future deleteFavoritePlace(int id) async {
    try {
      print("start viewmodel deleteFavoritePlace");
      await repository.deleteFavoritePlace(id);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future getPurposeListData() async {
    try {
      _purposeList = await repository.getPurposeListDataRepository();
      return _purposeList;
    } on Exception catch (exception) {
      debugPrint("HomeViewModel getPurposeList error");
      Exception(exception);
      return [];
    }
  }

  Future<LatLng> getCurrentPosition() async {
    await LocationManager.shared.request();
    var position = await LocationManager.shared.determinePosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future getPurposeDataViewModel() async {
    try {
      _purposeList = await repository.getPurposeListDataRepository();
    } on Exception catch (exception) {
      debugPrint("HomeViewModel getPurposeList error");
      Exception(exception);
      return [];
    }
  }

  Future<Set<Marker>> getMarkerList() async {
    Set<Marker> markers = {};
    for (var favoritePlace in _favoritePlaces) {
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

      markers.add(
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
    print("markers");
    print(markers);
    return markers;
  }
}
