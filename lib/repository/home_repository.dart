import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/api/controller/database/favorite_place_service.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) =>
    HomeRepository(service: ref.read(favoritePlaceServiceProvider)));

class HomeRepository {
  final FavoritePlaceService service;
  HomeRepository({required this.service});

  Future<List<FavoritePlaceEntity>> getFavoritePlaceData() async {
    try {
      final data = await service.getFavoritePlaceData();
      return data;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }

  Future<void> deleteFavoritePlace(int id) async {
    try {
      await service.deleteFavoritePlaceData(id);
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
