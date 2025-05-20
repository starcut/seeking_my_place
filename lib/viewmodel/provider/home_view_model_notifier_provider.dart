import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/model/home_model.dart';
import 'package:seeking_my_place/repository/provider/home_repository_provider.dart';
import 'package:seeking_my_place/viewmodel/home_view_model.dart';

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
