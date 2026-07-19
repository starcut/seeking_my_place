import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seeking_my_place/features/place/domain/entities/tabelog_info.dart';
import 'package:seeking_my_place/features/place/domain/usecases/fetch_tabelog_info_use_case.dart';

class PlaceInfoFetchService {
  PlaceInfoFetchService(this.ref);

  final WidgetRef ref;

  Future<TabelogInfo> fetch(String url) {
    return ref.read(fetchTabelogInfoUseCaseProvider(url).future);
  }

  void cancel(String url) {
    ref.invalidate(fetchTabelogInfoUseCaseProvider(url));
  }
}