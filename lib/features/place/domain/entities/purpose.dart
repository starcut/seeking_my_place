import 'package:freezed_annotation/freezed_annotation.dart';

part 'purpose.freezed.dart';
part 'purpose.g.dart';

@freezed
class Purpose with _$Purpose {
  const factory Purpose({
    required String purposeId,
    required String purposeName,
  }) = _Purpose;

  factory Purpose.fromJson(Map<String, dynamic> json) =>
      _$PurposeFromJson(json);
}
