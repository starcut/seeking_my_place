import 'package:flutter/material.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:seeking_my_place/repository/interface/home_repository_impl.dart';

class HomeViewModel {
  final HomeRepositoryImpl repository;
  HomeViewModel({required this.repository});

  late HomeModel _favoritePlaces;
  HomeModel get favoritePlaces => _favoritePlaces;

  late HomeModel _purposeList;
  HomeModel get purposeList => _purposeList;

  bool isLoading = false;

  Future getFavoritePlace() async {
    try {
      _favoritePlaces = await repository.getFavoritePlaceData();
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future getPurposeListData() async {
    try {
      _purposeList = await repository.getPurposeListData();
      return _purposeList;
    } on Exception catch (exception) {
      debugPrint("HomeViewModel getPurposeList error");
      Exception(exception);
      return [];
    }
  }
}
