import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/database/database_manager.dart';
import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final favoritePlaceServiceProvider =
    Provider<FavoritePlaceService>(
        (ref) => FavoritePlaceService(dio: ref.read(dioProvider)));

class FavoritePlaceService {
  final Dio dio;
  FavoritePlaceService({required this.dio});

  Future<List<FavoritePlaceEntity>> getFavoritePlaceData() async {
    try {
      print("start getFavoritePlaceData");
      final places = await DatabaseManager.shared.selectAllPlaces();
      return places;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<void> insertFavoritePlaceData(FavoritePlaceEntity favoritePlaceData) async {
    try {
      await DatabaseManager.shared.insertRegisterPlaceData(favoritePlaceData);
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<List<PurposeEntity>> getPurposeListDataService() async {
    try {
      final purposeMaster = await DatabaseManager.shared.selectAllPurposeMasterData();
      return purposeMaster;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<void> deleteFavoritePlaceData(int id) async {
    try {
      await DatabaseManager.shared.deleterFavoritePlace(id);
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
