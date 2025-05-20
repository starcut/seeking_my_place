import 'package:seeking_my_place/model/setting_model.dart';

abstract class SettingRepositoryImpl {
  Future<void> initDatabase();
  Future<SettingModel> selectAll();
  Future<void> insertPurposeData(String purposeName);
  Future<void> deletePurposeData(int id);
}
