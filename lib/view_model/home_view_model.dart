import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

import 'package:seeking_my_place/repository/home_repository.dart';

final homeViewModelNotifierProvider = FutureProvider<List<FavoritePlaceEntity>>((ref) async {
  print("start homeViewModelNotifierProvider");
  final viewModel = HomeViewModel(repository: ref.read(homeRepositoryProvider));
  await viewModel.getFavoritePlace();
  return viewModel.favoritePlaces;
});

final purposeListStateNotifierProvider =
    StateNotifierProvider<Purpose, int>((ref) {
  return Purpose(ref);
});

class Purpose extends StateNotifier<int> {
  Purpose(this.ref) : super(0);

  final Ref ref;

  Future<List<PurposeEntity>> getPurposeList() async {
    debugPrint("getPurposeList");
    final repository = ref.read(homeRepositoryProvider);
    final homeModel = repository.getPurposeListData();
    return homeModel;
  }
}

class HomeViewModel {
  final HomeRepository repository;

  HomeViewModel({required this.repository});

  late List<FavoritePlaceEntity> _favoritePlaces;
  List<FavoritePlaceEntity> get favoritePlaces => _favoritePlaces;

  late List<PurposeEntity> _purposeList;
  List<PurposeEntity> get purposeList => _purposeList;

  bool isLoading = false;

  Future getFavoritePlace() async {
    try {
      print("start viewmodel getFavoritePlace");
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

  Future getPurposeData() async {
    try {
      _purposeList = await repository.getPurposeListData();
    } on Exception catch (exception) {
      debugPrint("HomeViewModel getPurposeList error");
      Exception(exception);
      return [];
    }
  }
}
