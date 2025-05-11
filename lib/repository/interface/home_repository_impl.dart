import 'package:seeking_my_place/model/home_model.dart';

abstract class HomeRepositoryImpl {
  Future<HomeModel> getFavoritePlaceData();
}
