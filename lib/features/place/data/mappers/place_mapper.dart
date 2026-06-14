import 'package:seeking_my_place/features/place/data/dto/place_dto.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';

extension PlaceDtoMapper on PlaceDto {
  Place toEntity() {
    return Place(
      placeId: placeId,
      placeName: placeName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      url: url,
      category: category,
      isVisited: isVisited == 1,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

extension PlaceEntityMapper on Place {
  PlaceDto toDto() {
    return PlaceDto(
      placeId: placeId,
      placeName: placeName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      url: url,
      category: category,
      isVisited: isVisited ? 1 : 0,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
    );
  }
}
