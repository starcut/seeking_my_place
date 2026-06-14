import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';

class PlaceDto {
  final String placeId;
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final String url;
  final String category;
  final int isVisited;
  final String createdAt;
  final String updatedAt;

  const PlaceDto({
    required this.placeId,
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.url,
    required this.category,
    required this.isVisited,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaceDto.fromRow(Map<String, dynamic> row) {
    return PlaceDto(
      placeId: row[DatabaseHelper.colPlaceId] as String,
      placeName: row[DatabaseHelper.colPlaceName] as String,
      address: row[DatabaseHelper.colAddress] as String,
      latitude: (row[DatabaseHelper.colLatitude] as num).toDouble(),
      longitude: (row[DatabaseHelper.colLongitude] as num).toDouble(),
      url: row[DatabaseHelper.colUrl] as String,
      category: row[DatabaseHelper.colCategory] as String,
      isVisited: row[DatabaseHelper.colIsVisited] as int,
      createdAt: row[DatabaseHelper.colCreatedAt] as String,
      updatedAt: row[DatabaseHelper.colUpdatedAt] as String,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      DatabaseHelper.colPlaceId: placeId,
      DatabaseHelper.colPlaceName: placeName,
      DatabaseHelper.colAddress: address,
      DatabaseHelper.colLatitude: latitude,
      DatabaseHelper.colLongitude: longitude,
      DatabaseHelper.colUrl: url,
      DatabaseHelper.colCategory: category,
      DatabaseHelper.colIsVisited: isVisited,
      DatabaseHelper.colCreatedAt: createdAt,
      DatabaseHelper.colUpdatedAt: updatedAt,
    };
  }
}
