import 'package:freezed_annotation/freezed_annotation.dart';

part 'tabelog_info.freezed.dart';

/// 食べログのページから抽出した店舗情報を表すモデル。
@freezed
abstract class TabelogInfo with _$TabelogInfo {
  const factory TabelogInfo({
    /// 店舗名
    required String name,

    /// 住所
    required String address,

    /// ジャンル
    required String genre,
  }) = _TabelogInfo;
}
