import 'package:flutter/material.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:seeking_my_place/repository/home_repository.dart';
import 'package:seeking_my_place/repository/interface/home_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeViewModelNotifierProvider = FutureProvider<HomeModel>((ref) async {
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

  Future<HomeModel> getPurposeList() {
    final repository = ref.read(homeRepositoryProvider);
    final homeModel = repository.getPurposeListData();
    return homeModel;
  }
}

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
