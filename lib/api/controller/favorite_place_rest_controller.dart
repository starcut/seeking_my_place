import 'package:dartz/dartz_unsafe.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:seeking_my_place/api/controller/favorite_place_rest_controller_impl.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class FavoritePlaceRestController implements HomeViewRestControllerImpl {
  final Dio dio;
  FavoritePlaceRestController({required this.dio});

  String _dummy = "";
  @override
  Future<HomeModel> getFavoritePlaceData() async {
    const apiUrl = "";
    try {
      String dummy = await rootBundle.loadString("json/dummy_place.json");
      final response = json.decode(dummy);
      response.forEach((key, value) => _dummy = _dummy + '$key: $value \x0A');
      // final response = await dio.get(apiUrl);
      final List<dynamic> datas = response['favorite_place_data'];
      final models = HomeModel();
      for (dynamic data in datas) {
        final model = FavoritePlaceEntity.fromData(data);
        models.favoritePlaces.add(model);
      }
      return models;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  @override
  Future<HomeModel> getPurposeListData() async {
    try {
      String dummy =
          await rootBundle.loadString("json/dummy_purpose_list.json");
      final response = json.decode(dummy);
      response.forEach((key, value) => _dummy = _dummy + '$key: $value \x0A');
      final List<dynamic> data = response['purpose_list'];
      final models = HomeModel();
      for (dynamic item in data) {
        final model = PurposeEntity.fromData(item);
        models.purposeLists.add(model);
      }
      return models;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
