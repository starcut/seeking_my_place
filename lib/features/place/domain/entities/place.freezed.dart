// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Place {

 String get placeId; String get placeName; String get address; double get latitude; double get longitude; String get url; String get category; bool get isVisited; DateTime get createdAt; DateTime get updatedAt; List<Purpose> get purposes;
/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceCopyWith<Place> get copyWith => _$PlaceCopyWithImpl<Place>(this as Place, _$identity);

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Place&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.url, url) || other.url == url)&&(identical(other.category, category) || other.category == category)&&(identical(other.isVisited, isVisited) || other.isVisited == isVisited)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.purposes, purposes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,placeName,address,latitude,longitude,url,category,isVisited,createdAt,updatedAt,const DeepCollectionEquality().hash(purposes));

@override
String toString() {
  return 'Place(placeId: $placeId, placeName: $placeName, address: $address, latitude: $latitude, longitude: $longitude, url: $url, category: $category, isVisited: $isVisited, createdAt: $createdAt, updatedAt: $updatedAt, purposes: $purposes)';
}


}

/// @nodoc
abstract mixin class $PlaceCopyWith<$Res>  {
  factory $PlaceCopyWith(Place value, $Res Function(Place) _then) = _$PlaceCopyWithImpl;
@useResult
$Res call({
 String placeId, String placeName, String address, double latitude, double longitude, String url, String category, bool isVisited, DateTime createdAt, DateTime updatedAt, List<Purpose> purposes
});




}
/// @nodoc
class _$PlaceCopyWithImpl<$Res>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._self, this._then);

  final Place _self;
  final $Res Function(Place) _then;

/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? placeName = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? url = null,Object? category = null,Object? isVisited = null,Object? createdAt = null,Object? updatedAt = null,Object? purposes = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isVisited: null == isVisited ? _self.isVisited : isVisited // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,purposes: null == purposes ? _self.purposes : purposes // ignore: cast_nullable_to_non_nullable
as List<Purpose>,
  ));
}

}


/// Adds pattern-matching-related methods to [Place].
extension PlacePatterns on Place {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Place value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Place value)  $default,){
final _that = this;
switch (_that) {
case _Place():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Place value)?  $default,){
final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String placeName,  String address,  double latitude,  double longitude,  String url,  String category,  bool isVisited,  DateTime createdAt,  DateTime updatedAt,  List<Purpose> purposes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that.placeId,_that.placeName,_that.address,_that.latitude,_that.longitude,_that.url,_that.category,_that.isVisited,_that.createdAt,_that.updatedAt,_that.purposes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String placeName,  String address,  double latitude,  double longitude,  String url,  String category,  bool isVisited,  DateTime createdAt,  DateTime updatedAt,  List<Purpose> purposes)  $default,) {final _that = this;
switch (_that) {
case _Place():
return $default(_that.placeId,_that.placeName,_that.address,_that.latitude,_that.longitude,_that.url,_that.category,_that.isVisited,_that.createdAt,_that.updatedAt,_that.purposes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String placeName,  String address,  double latitude,  double longitude,  String url,  String category,  bool isVisited,  DateTime createdAt,  DateTime updatedAt,  List<Purpose> purposes)?  $default,) {final _that = this;
switch (_that) {
case _Place() when $default != null:
return $default(_that.placeId,_that.placeName,_that.address,_that.latitude,_that.longitude,_that.url,_that.category,_that.isVisited,_that.createdAt,_that.updatedAt,_that.purposes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Place implements Place {
  const _Place({required this.placeId, required this.placeName, required this.address, required this.latitude, required this.longitude, required this.url, required this.category, required this.isVisited, required this.createdAt, required this.updatedAt, final  List<Purpose> purposes = const []}): _purposes = purposes;
  factory _Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

@override final  String placeId;
@override final  String placeName;
@override final  String address;
@override final  double latitude;
@override final  double longitude;
@override final  String url;
@override final  String category;
@override final  bool isVisited;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<Purpose> _purposes;
@override@JsonKey() List<Purpose> get purposes {
  if (_purposes is EqualUnmodifiableListView) return _purposes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_purposes);
}


/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceCopyWith<_Place> get copyWith => __$PlaceCopyWithImpl<_Place>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Place&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.url, url) || other.url == url)&&(identical(other.category, category) || other.category == category)&&(identical(other.isVisited, isVisited) || other.isVisited == isVisited)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._purposes, _purposes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,placeName,address,latitude,longitude,url,category,isVisited,createdAt,updatedAt,const DeepCollectionEquality().hash(_purposes));

@override
String toString() {
  return 'Place(placeId: $placeId, placeName: $placeName, address: $address, latitude: $latitude, longitude: $longitude, url: $url, category: $category, isVisited: $isVisited, createdAt: $createdAt, updatedAt: $updatedAt, purposes: $purposes)';
}


}

/// @nodoc
abstract mixin class _$PlaceCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$PlaceCopyWith(_Place value, $Res Function(_Place) _then) = __$PlaceCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String placeName, String address, double latitude, double longitude, String url, String category, bool isVisited, DateTime createdAt, DateTime updatedAt, List<Purpose> purposes
});




}
/// @nodoc
class __$PlaceCopyWithImpl<$Res>
    implements _$PlaceCopyWith<$Res> {
  __$PlaceCopyWithImpl(this._self, this._then);

  final _Place _self;
  final $Res Function(_Place) _then;

/// Create a copy of Place
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? placeName = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? url = null,Object? category = null,Object? isVisited = null,Object? createdAt = null,Object? updatedAt = null,Object? purposes = null,}) {
  return _then(_Place(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isVisited: null == isVisited ? _self.isVisited : isVisited // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,purposes: null == purposes ? _self._purposes : purposes // ignore: cast_nullable_to_non_nullable
as List<Purpose>,
  ));
}


}

// dart format on
