import 'package:flutter/material.dart';
import 'package:seeking_my_place/api/controller/favorite_place_rest_controller_impl.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:seeking_my_place/repository/interface/home_repository_impl.dart';

class HomeRepository implements HomeRepositoryImpl {
  final FavoritePlaceRestControllerImpl repository;
  HomeRepository({required this.repository});

  @override
  Future<HomeModel> getFavoritePlaceData() async {
    try {
      final data = await repository.getFavoritePlaceData();
      return data;
    } on Exception catch (exception) {
      throw Exception(exception);
    }
  }
}
