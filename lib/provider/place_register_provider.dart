import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:seeking_my_place/Common/Enum/InputItem.dart';
import 'package:seeking_my_place/api/controller/database_manager.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

// 1. TextFieldの値を管理するプロバイダーを作成
final urlTextFieldProvider = StateNotifierProvider<TextFieldNotifier, String>((ref) {
  return TextFieldNotifier();
});
final placeNameTextFieldProvider = StateNotifierProvider<TextFieldNotifier, String>((ref) {
  return TextFieldNotifier();
});
final addressTextFieldProvider = StateNotifierProvider<TextFieldNotifier, String>((ref) {
  return TextFieldNotifier();
});
final categoryTextFieldProvider = StateNotifierProvider<TextFieldNotifier, String>((ref) {
  return TextFieldNotifier();
});

class TextFieldNotifier extends StateNotifier<String> {
  TextFieldNotifier() : super('');

  void updateText(String text) {
    state = text;
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
        break;
      case InputItem.placeName:
        startRemoveString = "<span class=\"rstdtl-crumb\">";
        endRemoveString = '</span>';
        regExpString = r'<span class="rstdtl-crumb">(.*?)</span>';
        break;
      case InputItem.address:
        startRemoveString = 'data-send-address="';
        endRemoveString = '"';
        regExpString = r'data-send-address="([\s\S]*?)"';
        break;
      case InputItem.category:
        startRemoveString = '<span class="linktree__parent-target-text">';
        endRemoveString = '</span>';
        regExpString = r'<span class="linktree__parent-target-text">(.*?)</span>';
        break;
      default:
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

final isVisitedTextFieldProvider = StateNotifierProvider<CheckBoxNotifier, bool>((ref) {
  return CheckBoxNotifier();
});

class CheckBoxNotifier extends StateNotifier<bool> {
  CheckBoxNotifier() : super(false);

  void updateText(bool isChecked) {
    state = isChecked;
  }
}

final purposeTextFieldProvider = StateNotifierProvider<PurposeNotifier, PurposeEntity>((ref) {
  return PurposeNotifier();
});

class PurposeNotifier extends StateNotifier<PurposeEntity> {
  PurposeNotifier() : super(PurposeEntity(id: 0, purposeName: "未設定")) {
    getPurposeList();
  }

  Future<List<PurposeEntity>> getPurposeList() async {
    return await DatabaseManager.shared.selectAllPurposeMasterData();
  }

  Future<void> updateText(int purposeId) async {
    final selectedPurpose = await DatabaseManager.shared.getPurposeMasterData(purposeId)
        ?? PurposeEntity(id: 0, purposeName: "未設定");
    state = selectedPurpose;
  }
}


final placeRegisterNotifier = StateNotifierProvider.autoDispose<PlaceRegisterNotifier, void>((ref) {
  return PlaceRegisterNotifier();
});

/// StateNotifierProvider に渡すことになる StateNotifier クラスです。
class PlaceRegisterNotifier extends StateNotifier<void> {
  PlaceRegisterNotifier() : super(0);

  Future insertFavoriteData(FavoritePlaceEntity favoritePlaceData) async {
    try {
      await DatabaseManager.shared.insertRegisterPlaceData(favoritePlaceData);
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}