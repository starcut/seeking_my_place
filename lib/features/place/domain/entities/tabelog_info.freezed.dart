// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tabelog_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TabelogInfo {

/// 店舗名
 String get name;/// 住所
 String get address;/// ジャンル
 String get genre;
/// Create a copy of TabelogInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TabelogInfoCopyWith<TabelogInfo> get copyWith => _$TabelogInfoCopyWithImpl<TabelogInfo>(this as TabelogInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TabelogInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.genre, genre) || other.genre == genre));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,genre);

@override
String toString() {
  return 'TabelogInfo(name: $name, address: $address, genre: $genre)';
}


}

/// @nodoc
abstract mixin class $TabelogInfoCopyWith<$Res>  {
  factory $TabelogInfoCopyWith(TabelogInfo value, $Res Function(TabelogInfo) _then) = _$TabelogInfoCopyWithImpl;
@useResult
$Res call({
 String name, String address, String genre
});




}
/// @nodoc
class _$TabelogInfoCopyWithImpl<$Res>
    implements $TabelogInfoCopyWith<$Res> {
  _$TabelogInfoCopyWithImpl(this._self, this._then);

  final TabelogInfo _self;
  final $Res Function(TabelogInfo) _then;

/// Create a copy of TabelogInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? address = null,Object? genre = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TabelogInfo].
extension TabelogInfoPatterns on TabelogInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TabelogInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TabelogInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TabelogInfo value)  $default,){
final _that = this;
switch (_that) {
case _TabelogInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TabelogInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TabelogInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String address,  String genre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TabelogInfo() when $default != null:
return $default(_that.name,_that.address,_that.genre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String address,  String genre)  $default,) {final _that = this;
switch (_that) {
case _TabelogInfo():
return $default(_that.name,_that.address,_that.genre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String address,  String genre)?  $default,) {final _that = this;
switch (_that) {
case _TabelogInfo() when $default != null:
return $default(_that.name,_that.address,_that.genre);case _:
  return null;

}
}

}

/// @nodoc


class _TabelogInfo implements TabelogInfo {
  const _TabelogInfo({required this.name, required this.address, required this.genre});
  

/// 店舗名
@override final  String name;
/// 住所
@override final  String address;
/// ジャンル
@override final  String genre;

/// Create a copy of TabelogInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabelogInfoCopyWith<_TabelogInfo> get copyWith => __$TabelogInfoCopyWithImpl<_TabelogInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabelogInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.genre, genre) || other.genre == genre));
}


@override
int get hashCode => Object.hash(runtimeType,name,address,genre);

@override
String toString() {
  return 'TabelogInfo(name: $name, address: $address, genre: $genre)';
}


}

/// @nodoc
abstract mixin class _$TabelogInfoCopyWith<$Res> implements $TabelogInfoCopyWith<$Res> {
  factory _$TabelogInfoCopyWith(_TabelogInfo value, $Res Function(_TabelogInfo) _then) = __$TabelogInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String address, String genre
});




}
/// @nodoc
class __$TabelogInfoCopyWithImpl<$Res>
    implements _$TabelogInfoCopyWith<$Res> {
  __$TabelogInfoCopyWithImpl(this._self, this._then);

  final _TabelogInfo _self;
  final $Res Function(_TabelogInfo) _then;

/// Create a copy of TabelogInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? address = null,Object? genre = null,}) {
  return _then(_TabelogInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
