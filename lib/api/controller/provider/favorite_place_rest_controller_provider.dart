import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/favorite_place_rest_controller.dart';
import 'package:seeking_my_place/api/controller/favorite_place_rest_controller_impl.dart';
import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';

final favoritePlaceRestControllerProvider =
    Provider<HomeViewRestControllerImpl>(
        (ref) => FavoritePlaceRestController(dio: ref.read(dioProvider)));
