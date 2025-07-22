import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final favoritePlaceRestControllerProvider =
    Provider<FavoritePlaceService>(
        (ref) => FavoritePlaceService(dio: ref.read(dioProvider)));

class FavoritePlaceService {
  final Dio dio;
  FavoritePlaceService({required this.dio});

  String _dummy = "";
  @override
  Future<List<FavoritePlaceEntity>> getFavoritePlaceData() async {
    const apiUrl = "";
    try {
      String dummy = await rootBundle.loadString("json/dummy_place.json");
      final response = json.decode(dummy);
      response.forEach((key, value) => _dummy = _dummy + '$key: $value \x0A');
      // final response = await dio.get(apiUrl);
      final List<dynamic> datas = response['favorite_place_data'];
      final models = <FavoritePlaceEntity>[];
      for (dynamic data in datas) {
        final model = FavoritePlaceEntity.fromData(data);
        models.add(model);
      }
      return models;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  @override
  Future<List<PurposeEntity>> getPurposeListData() async {
    try {
      String dummy =
          await rootBundle.loadString("json/dummy_purpose_list.json");
      final response = json.decode(dummy);
      response.forEach((key, value) => _dummy = _dummy + '$key: $value \x0A');
      final List<dynamic> data = response['purpose_list'];
      final models = <PurposeEntity>[];
      for (dynamic item in data) {
        final model = PurposeEntity.fromData(item);
        models.add(model);
      }
      return models;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
