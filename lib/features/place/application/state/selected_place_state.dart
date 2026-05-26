import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_place_state.g.dart';

@riverpod
class SelectedPlaceState extends _$SelectedPlaceState {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}
