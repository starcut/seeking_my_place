import 'package:seeking_my_place/model/home_model.dart';

abstract class HomeViewRestControllerImpl {
  Future<HomeModel> getFavoritePlaceData();
  Future<HomeModel> getPurposeListData();
}
