import 'package:seeking_my_place/entity/purpose_entity.dart';

class SettingModel {
  List<PurposeEntity> purposeLists = <PurposeEntity>[];
  PurposeEntity selectedPurposeData = PurposeEntity(
      id: 0,
      purposeName: "",
      registerAt: DateTime.now(),
      updateAt: DateTime.now());
}
