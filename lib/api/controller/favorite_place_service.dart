import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/database_manager.dart';

import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final favoritePlaceRestControllerProvider =
    Provider<FavoritePlaceService>(
        (ref) => FavoritePlaceService(dio: ref.read(dioProvider)));

class FavoritePlaceService {
  final Dio dio;
  FavoritePlaceService({required this.dio});

  Future<List<FavoritePlaceEntity>> getFavoritePlaceData() async {
    try {
      print("start getFavoritePlaceData");
      final places = await DatabaseManager.shared.selectAllPlaces();
      final models = <FavoritePlaceEntity>[];
      for (dynamic data in places) {
        final model = FavoritePlaceEntity.fromData(data);
        models.add(model);
      }
      return models;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<List<PurposeEntity>> getPurposeListData() async {
    try {
      final purposeMaster = await DatabaseManager.shared.selectAllPurposeMasterData();
      return purposeMaster;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
