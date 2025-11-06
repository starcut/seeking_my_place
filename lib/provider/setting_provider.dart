import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/database/database_manager.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rangeSettingProvider = StateNotifierProvider<RangeNotifier, double>((ref) {
  return RangeNotifier();
});

class RangeNotifier extends StateNotifier<double> {
  RangeNotifier() : super(10) {
    loadRange();
  }

  Future<void> loadRange() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('display_range') ?? 10;
  }

  Future<void> updateRange(double range) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = range;
    await prefs.setDouble('display_range', state);
  }
}

class ListCountData {
  final int listCount;
  final int selectedIndex;

  ListCountData({
    required this.listCount,
    required this.selectedIndex
  });
}

final listCountSettingProvider = StateNotifierProvider<ListCountNotifier, ListCountData>((ref) {
  return ListCountNotifier();
});

class ListCountNotifier extends StateNotifier<ListCountData> {
  ListCountNotifier() : super(ListCountData(listCount: 10, selectedIndex: 0)) {
    loadListCount();
  }

  Future<void> loadListCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final listCount = await prefs.getInt('display_count') ?? 10;
    final selectedIndex = await prefs.getInt('display_count_index') ?? 0;
    state = ListCountData(listCount: listCount, selectedIndex: selectedIndex);
  }

  Future<void> updateListCount(int count, int selectedIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('display_count', count);
    await prefs.setInt('display_count_index', selectedIndex);
    state = ListCountData(listCount: count, selectedIndex: selectedIndex);
  }
}

final purposeListSettingProvider = StateNotifierProvider<PurposeListNotifier, List<PurposeEntity>>((ref) {
  return PurposeListNotifier([]);
});

class PurposeListNotifier extends StateNotifier<List<PurposeEntity>> {
  PurposeListNotifier(List<PurposeEntity> state) : super([]) {
    getPurposeListAll();
  }

  Future getPurposeListAll() async {
    state = await DatabaseManager.shared.selectAllPurposeMasterData();
  }

  Future<PurposeEntity?> getPurposeEntity(int purposeId) async {
    var purpose = await DatabaseManager.shared.getPurposeMasterData(purposeId);
    return purpose;
  }

  void insertPurpose(String purposeName) async {
    await DatabaseManager.shared.insertPurpose(purposeName);
    await getPurposeListAll();
  }

  Future<void> updatePurpose(PurposeEntity purpose) async {
    await DatabaseManager.shared.updatePurposeMasterData(purpose);
    await getPurposeListAll();
  }

  Future<void> deletePurpose(int deleteId) async {
    await DatabaseManager.shared.deletePurposeMasterData(deleteId);
    await getPurposeListAll();
  }
}
