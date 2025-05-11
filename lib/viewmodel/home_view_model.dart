import 'package:flutter/material.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:seeking_my_place/repository/interface/home_repository_impl.dart';

class HomeViewModel {
  final HomeRepositoryImpl repository;
  HomeViewModel({required this.repository});

  late HomeModel _favoritePlaces;
  HomeModel get favoritePlaces => _favoritePlaces;

  bool isLoading = false;

  Future getFavoritePlace() async {
    try {
      final data = await repository.getFavoritePlaceData();
      _favoritePlaces = data;
    } on Exception catch (exception) {
      Exception(exception);
    }
  }
}
