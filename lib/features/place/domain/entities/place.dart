import 'package:freezed_annotation/freezed_annotation.dart';

import 'purpose.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String placeId,
    required String placeName,
    required String address,
    required double latitude,
    required double longitude,
    required String url,
    required String category,
    required bool isVisited,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<Purpose> purposes,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
