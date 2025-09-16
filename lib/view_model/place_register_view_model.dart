import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';

import 'package:seeking_my_place/repository/place_register_repository.dart';
import 'package:seeking_my_place/view/place_register_view.dart';

final placeRegisterViewModelInsertDataProvider =
FutureProvider.family<void, FavoritePlaceEntity>((ref, favoritePlaceData) async {
  final viewModel =
  PlaceRegisterViewModel(repository: ref.read(placeRegisterRepositoryProvider));
  await viewModel.insertPurposeData(favoritePlaceData);
});

final placeRegisterViewModelNotifierProvider = AutoDisposeStateProvider<PlaceRegisterViewModel>((ref) {
  return PlaceRegisterViewModel(repository: ref.read(placeRegisterRepositoryProvider));
});

class PlaceRegisterViewModel {
  final PlaceRegisterRepository repository;

  PlaceRegisterViewModel({required this.repository});

  String url = "";
  String placeName = "";
  String address = "";
  String category = "";
  String purpose = "";
  bool isVisited = false;
  bool isLoading = false;

  Future insertPurposeData(FavoritePlaceEntity favoritePlaceData) async {
    try {
      await repository.insertFavoritePlaceData(favoritePlaceData);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  void setFavoritePlaceData(InputItem inputItem, String text) {
    switch (inputItem) {
      case InputItem.url:
        url = text;
      case InputItem.placeName:
        placeName = text;
      case InputItem.address:
        address = text;
      case InputItem.category:
        category = text;
      case InputItem.purpose:
        purpose = text;
      default:
        debugPrint("input error");
        throw UnimplementedError();
    }
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> location = await locationFromAddress(address);
      if (location.isEmpty) {
        return null;
      }
      return LatLng(location.first.latitude, location.first.longitude);
    } catch (e) {
      print("error: $e");
      return null;
    }
  }
}
