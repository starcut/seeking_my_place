import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/provider/favorite_place_rest_controller_provider.dart';
import 'package:seeking_my_place/repository/home_repository.dart';
import 'package:seeking_my_place/repository/interface/home_repository_impl.dart';

final homeRepositoryProvider = Provider<HomeRepositoryImpl>((ref) =>
    HomeRepository(repository: ref.read(favoritePlaceRestControllerProvider)));
