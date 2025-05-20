import 'package:seeking_my_place/model/setting_model.dart';
import 'package:seeking_my_place/repository/interface/setting_repository_impl.dart';

class SettingViewModel {
  final SettingRepositoryImpl repository;

  SettingViewModel({required this.repository});

  late SettingModel _purposeList;
  SettingModel get purposeList => _purposeList;

  bool isLoading = false;

  Future selectAll() async {
    try {
      await repository.initDatabase();
      _purposeList = await repository.selectAll();
    } on Exception catch (exception) {
      Exception(exception);
    }
  }

  Future insertPurposeData(String purposeName) async {
    try {
      await repository.initDatabase();
      await repository.insertPurposeData(purposeName);
    } on Exception catch (exception) {
      Exception(exception);
    }
  }
}
