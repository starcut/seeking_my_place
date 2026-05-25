// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purpose.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Purpose _$PurposeFromJson(Map<String, dynamic> json) {
  return _Purpose.fromJson(json);
}

/// @nodoc
mixin _$Purpose {
  String get purposeId => throw _privateConstructorUsedError;
  String get purposeName => throw _privateConstructorUsedError;

  /// Serializes this Purpose to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Purpose
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurposeCopyWith<Purpose> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurposeCopyWith<$Res> {
  factory $PurposeCopyWith(Purpose value, $Res Function(Purpose) then) =
      _$PurposeCopyWithImpl<$Res, Purpose>;
  @useResult
  $Res call({String purposeId, String purposeName});
}

/// @nodoc
class _$PurposeCopyWithImpl<$Res, $Val extends Purpose>
    implements $PurposeCopyWith<$Res> {
  _$PurposeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Purpose
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purposeId = null,
    Object? purposeName = null,
  }) {
    return _then(_value.copyWith(
      purposeId: null == purposeId
          ? _value.purposeId
          : purposeId // ignore: cast_nullable_to_non_nullable
              as String,
      purposeName: null == purposeName
          ? _value.purposeName
          : purposeName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurposeImplCopyWith<$Res> implements $PurposeCopyWith<$Res> {
  factory _$$PurposeImplCopyWith(
          _$PurposeImpl value, $Res Function(_$PurposeImpl) then) =
      __$$PurposeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String purposeId, String purposeName});
}

/// @nodoc
class __$$PurposeImplCopyWithImpl<$Res>
    extends _$PurposeCopyWithImpl<$Res, _$PurposeImpl>
    implements _$$PurposeImplCopyWith<$Res> {
  __$$PurposeImplCopyWithImpl(
      _$PurposeImpl _value, $Res Function(_$PurposeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Purpose
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? purposeId = null,
    Object? purposeName = null,
  }) {
    return _then(_$PurposeImpl(
      purposeId: null == purposeId
          ? _value.purposeId
          : purposeId // ignore: cast_nullable_to_non_nullable
              as String,
      purposeName: null == purposeName
          ? _value.purposeName
          : purposeName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurposeImpl implements _Purpose {
  const _$PurposeImpl({required this.purposeId, required this.purposeName});

  factory _$PurposeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurposeImplFromJson(json);

  @override
  final String purposeId;
  @override
  final String purposeName;

  @override
  String toString() {
    return 'Purpose(purposeId: $purposeId, purposeName: $purposeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurposeImpl &&
            (identical(other.purposeId, purposeId) ||
                other.purposeId == purposeId) &&
            (identical(other.purposeName, purposeName) ||
                other.purposeName == purposeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, purposeId, purposeName);

  /// Create a copy of Purpose
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurposeImplCopyWith<_$PurposeImpl> get copyWith =>
      __$$PurposeImplCopyWithImpl<_$PurposeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurposeImplToJson(
      this,
    );
  }
}

abstract class _Purpose implements Purpose {
  const factory _Purpose(
      {required final String purposeId,
      required final String purposeName}) = _$PurposeImpl;

  factory _Purpose.fromJson(Map<String, dynamic> json) = _$PurposeImpl.fromJson;

  @override
  String get purposeId;
  @override
  String get purposeName;

  /// Create a copy of Purpose
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurposeImplCopyWith<_$PurposeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
