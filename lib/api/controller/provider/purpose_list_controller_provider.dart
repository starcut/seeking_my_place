import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/purpose_list_controller.dart';
import 'package:seeking_my_place/api/controller/purpose_list_controller_impl.dart';

final purposeListControllerProvider =
    Provider<PurposeListControllerImpl>((ref) => PurposeListController());
