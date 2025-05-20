import 'package:seeking_my_place/model/setting_model.dart';

abstract class PurposeListControllerImpl {
  Future<void> initDatabaseExecute();
  Future<SettingModel> selectAllExecute();
  Future<void> insertPurposeDataExecute(String purposeName);
  Future<void> deletePurposeDataExecute(int id);
}
