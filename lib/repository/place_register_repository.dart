import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/database/favorite_place_service.dart';

import 'package:seeking_my_place/entity/favorite_place_entity.dart';

final placeRegisterRepositoryProvider = Provider<PlaceRegisterRepository>((ref) {
  return PlaceRegisterRepository(service: ref.read(favoritePlaceServiceProvider));
});

class PlaceRegisterRepository {
  final FavoritePlaceService service;
  PlaceRegisterRepository({required this.service});

  Future<void> insertFavoritePlaceData(FavoritePlaceEntity favoritePlaceData) async {
    try {
      final data = await service.insertFavoritePlaceData(favoritePlaceData);
      return data;
    } on Exception catch (exception) {
      debugPrint("PlaceRegisterRepository insertFavoritePlaceData error");
      throw Exception(exception);
    }
  }
}
