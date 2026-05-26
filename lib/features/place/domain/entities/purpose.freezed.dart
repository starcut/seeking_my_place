// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purpose.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Purpose {

 String get purposeId; String get purposeName;
/// Create a copy of Purpose
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurposeCopyWith<Purpose> get copyWith => _$PurposeCopyWithImpl<Purpose>(this as Purpose, _$identity);

  /// Serializes this Purpose to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Purpose&&(identical(other.purposeId, purposeId) || other.purposeId == purposeId)&&(identical(other.purposeName, purposeName) || other.purposeName == purposeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purposeId,purposeName);

@override
String toString() {
  return 'Purpose(purposeId: $purposeId, purposeName: $purposeName)';
}


}

/// @nodoc
abstract mixin class $PurposeCopyWith<$Res>  {
  factory $PurposeCopyWith(Purpose value, $Res Function(Purpose) _then) = _$PurposeCopyWithImpl;
@useResult
$Res call({
 String purposeId, String purposeName
});




}
/// @nodoc
class _$PurposeCopyWithImpl<$Res>
    implements $PurposeCopyWith<$Res> {
  _$PurposeCopyWithImpl(this._self, this._then);

  final Purpose _self;
  final $Res Function(Purpose) _then;

/// Create a copy of Purpose
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purposeId = null,Object? purposeName = null,}) {
  return _then(_self.copyWith(
purposeId: null == purposeId ? _self.purposeId : purposeId // ignore: cast_nullable_to_non_nullable
as String,purposeName: null == purposeName ? _self.purposeName : purposeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Purpose].
extension PurposePatterns on Purpose {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Purpose value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Purpose() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Purpose value)  $default,){
final _that = this;
switch (_that) {
case _Purpose():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Purpose value)?  $default,){
final _that = this;
switch (_that) {
case _Purpose() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String purposeId,  String purposeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Purpose() when $default != null:
return $default(_that.purposeId,_that.purposeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String purposeId,  String purposeName)  $default,) {final _that = this;
switch (_that) {
case _Purpose():
return $default(_that.purposeId,_that.purposeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String purposeId,  String purposeName)?  $default,) {final _that = this;
switch (_that) {
case _Purpose() when $default != null:
return $default(_that.purposeId,_that.purposeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Purpose implements Purpose {
  const _Purpose({required this.purposeId, required this.purposeName});
  factory _Purpose.fromJson(Map<String, dynamic> json) => _$PurposeFromJson(json);

@override final  String purposeId;
@override final  String purposeName;

/// Create a copy of Purpose
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurposeCopyWith<_Purpose> get copyWith => __$PurposeCopyWithImpl<_Purpose>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurposeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Purpose&&(identical(other.purposeId, purposeId) || other.purposeId == purposeId)&&(identical(other.purposeName, purposeName) || other.purposeName == purposeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purposeId,purposeName);

@override
String toString() {
  return 'Purpose(purposeId: $purposeId, purposeName: $purposeName)';
}


}

/// @nodoc
abstract mixin class _$PurposeCopyWith<$Res> implements $PurposeCopyWith<$Res> {
  factory _$PurposeCopyWith(_Purpose value, $Res Function(_Purpose) _then) = __$PurposeCopyWithImpl;
@override @useResult
$Res call({
 String purposeId, String purposeName
});




}
/// @nodoc
class __$PurposeCopyWithImpl<$Res>
    implements _$PurposeCopyWith<$Res> {
  __$PurposeCopyWithImpl(this._self, this._then);

  final _Purpose _self;
  final $Res Function(_Purpose) _then;

/// Create a copy of Purpose
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purposeId = null,Object? purposeName = null,}) {
  return _then(_Purpose(
purposeId: null == purposeId ? _self.purposeId : purposeId // ignore: cast_nullable_to_non_nullable
as String,purposeName: null == purposeName ? _self.purposeName : purposeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
