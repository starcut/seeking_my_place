import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/model/setting_model.dart';

abstract class PurposeListControllerImpl {
  Future<void> initDatabaseExecute();
  Future<SettingModel> selectAllExecute();
  Future<SettingModel> selectPurposeDataByIdExecute(int id);
  Future<void> insertPurposeDataExecute(String purposeName);
  Future<void> updatePurposeDataExecute(PurposeEntity entity);
  Future<void> deletePurposeDataExecute(int id);
}
