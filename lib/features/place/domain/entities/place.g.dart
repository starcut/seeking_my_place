// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      url: json['url'] as String,
      category: json['category'] as String,
      isVisited: json['isVisited'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      purposes: (json['purposes'] as List<dynamic>?)
              ?.map((e) => Purpose.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'placeName': instance.placeName,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'url': instance.url,
      'category': instance.category,
      'isVisited': instance.isVisited,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'purposes': instance.purposes.map((e) => e.toJson()).toList(),
    };
