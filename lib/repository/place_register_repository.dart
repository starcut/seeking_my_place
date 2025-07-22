import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/favorite_place_service.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

final homeRepositoryProvider = Provider<PlaceRegisterRepository>((ref) =>
    PlaceRegisterRepository(service: ref.read(favoritePlaceRestControllerProvider)));

class PlaceRegisterRepository {
  final FavoritePlaceService service;
  PlaceRegisterRepository({required this.service});

  Future<List<FavoritePlaceEntity>> registerFavoritePlaceData() async {
    try {
      final data = await service.getFavoritePlaceData();
      return data;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<List<PurposeEntity>> getPurposeListData() async {
    try {
      final data = await service.getPurposeListData();
      return data;
    } on Exception catch (exception) {
      debugPrint("HomeRepository getPurposeListData error");
      throw Exception(exception);
    }
  }
}
