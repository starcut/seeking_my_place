

import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:seeking_my_place/view/place_register_view.dart';

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
final purposeTextFieldProvider = StateNotifierProvider<TextFieldNotifier, String>((ref) {
  return TextFieldNotifier();
});
final isVisitedTextFieldProvider = StateNotifierProvider<CheckBoxNotifier, bool>((ref) {
  return CheckBoxNotifier();
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

class CheckBoxNotifier extends StateNotifier<bool> {
  CheckBoxNotifier() : super(false);

  void updateText(bool isChecked) {
    state = isChecked;
  }
}

class PurposeNotifier extends StateNotifier<int> {
  PurposeNotifier() : super(0);

  void updateText(int purposeId) {
    state = purposeId;
  }
}


final placeRegisterResultNotifier = StateNotifierProvider.autoDispose<PlaceRegisterResultNotifier, PlaceRegisterParams>((ref) {
  return PlaceRegisterResultNotifier();
});

class PlaceRegisterParams {
  String url = "";
  String placeName = "";
  String address = "";
  String category = "";
  String purpose = "";
  bool isVisited = false;
  bool isLoading = false;
}

/// StateNotifierProvider に渡すことになる StateNotifier クラスです。
class PlaceRegisterResultNotifier extends StateNotifier<PlaceRegisterParams> {
  PlaceRegisterResultNotifier() : super(defaultResultValue);

  static final defaultResultValue = PlaceRegisterParams();

  void initValue() {
    // state更新時にProviderを介してConsumer配下のWidgetがリビルドされる
    state = defaultResultValue;
  }

  void refresh() {
    initValue();
  }

  void setFavoritePlaceData(InputItem inputItem, String text) {
    switch (inputItem) {
      case InputItem.url:
        state.url = text;
      case InputItem.placeName:
        state.placeName = text;
      case InputItem.address:
        state.address = text;
      case InputItem.category:
        state.category = text;
      case InputItem.purpose:
        state.purpose = text;
      default:
        print("input error");
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

  void updateText(String url) {
    // state更新時にProviderを介してConsumer配下のWidgetがリビルドされる
    state.url = url;
  }

  void switchCheckBox(bool isVisited) {
    state.isVisited = isVisited;
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