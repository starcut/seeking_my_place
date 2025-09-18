import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
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

  Future<String> getPlaceDataFromHTML(String url, InputItem inputItem) async {
    var uri = Uri.parse(url);
    var bodyString = "";
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        print("body:");
        print(response.body);
        bodyString = response.body;
      } else {
        print('リクエストに失敗しました: ${response.statusCode}');
        return "";
      }
    } catch (e) {
      print('エラーが発生しました: $e');
      return "";
    }

    return _extractionInfo(bodyString, inputItem);
  }

  String _extractionInfo(String bodyString,InputItem inputItem) {
    String regExpString = "";
    String startRemoveString = '';
    String endRemoveString = '';
    switch(inputItem) {
      case InputItem.url:
        print("InputItem.url");
        break;
      case InputItem.placeName:
        print("InputItem.placeName");
        startRemoveString = "<span class=\"rstdtl-crumb\">";
        endRemoveString = '</span>';
        regExpString = r'<span class="rstdtl-crumb">(.*?)</span>';
        break;
      case InputItem.address:
        print("InputItem.address");
        startRemoveString = 'data-send-address="';
        endRemoveString = '"';
        regExpString = r'data-send-address="([\s\S]*?)"';
        break;
      case InputItem.purpose:
        print("InputItem.purpose");
        break;
      case InputItem.category:
        print("InputItem.category");
        startRemoveString = '<span class="linktree__parent-target-text">';
        endRemoveString = '</span>';
        regExpString = r'<span class="linktree__parent-target-text">(.*?)</span>';
        break;
      default:
        print("default");
        return "Not Found";
    }

    RegExp _regExp = RegExp(regExpString);
    Iterable<RegExpMatch> _matches = _regExp.allMatches(bodyString);
    var extractionString = "";
    for(RegExpMatch regExpMatch in _matches) {
      var str = bodyString.substring(regExpMatch.start, regExpMatch.end);
      str = str.replaceAll(startRemoveString, "");
      str = str.replaceAll(endRemoveString, "");
      extractionString = str;
    }
    return extractionString;
  }
}
