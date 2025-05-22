import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/setting_model.dart';

abstract class SettingRepositoryImpl {
  Future<void> initDatabase();
  Future<SettingModel> selectAll();
  Future<SettingModel> selectPurposeDataById(int id);
  Future<void> insertPurposeData(String purposeName);
  Future<void> updatePurposeData(PurposeEntity entity);
  Future<void> deletePurposeData(int id);
}
