// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metric_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MetricRecord _$MetricRecordFromJson(Map<String, dynamic> json) {
  return _MetricRecord.fromJson(json);
}

/// @nodoc
mixin _$MetricRecord {
  String get id => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get metricType => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  Map<String, dynamic>? get valueExtra => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MetricRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MetricRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetricRecordCopyWith<MetricRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricRecordCopyWith<$Res> {
  factory $MetricRecordCopyWith(
          MetricRecord value, $Res Function(MetricRecord) then) =
      _$MetricRecordCopyWithImpl<$Res, MetricRecord>;
  @useResult
  $Res call(
      {String id,
      String memberId,
      String metricType,
      double value,
      Map<String, dynamic>? valueExtra,
      String unit,
      DateTime recordedAt,
      String? note,
      DateTime createdAt});
}

/// @nodoc
class _$MetricRecordCopyWithImpl<$Res, $Val extends MetricRecord>
    implements $MetricRecordCopyWith<$Res> {
  _$MetricRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MetricRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? metricType = null,
    Object? value = null,
    Object? valueExtra = freezed,
    Object? unit = null,
    Object? recordedAt = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      valueExtra: freezed == valueExtra
          ? _value.valueExtra
          : valueExtra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetricRecordImplCopyWith<$Res>
    implements $MetricRecordCopyWith<$Res> {
  factory _$$MetricRecordImplCopyWith(
          _$MetricRecordImpl value, $Res Function(_$MetricRecordImpl) then) =
      __$$MetricRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String memberId,
      String metricType,
      double value,
      Map<String, dynamic>? valueExtra,
      String unit,
      DateTime recordedAt,
      String? note,
      DateTime createdAt});
}

/// @nodoc
class __$$MetricRecordImplCopyWithImpl<$Res>
    extends _$MetricRecordCopyWithImpl<$Res, _$MetricRecordImpl>
    implements _$$MetricRecordImplCopyWith<$Res> {
  __$$MetricRecordImplCopyWithImpl(
      _$MetricRecordImpl _value, $Res Function(_$MetricRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of MetricRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? metricType = null,
    Object? value = null,
    Object? valueExtra = freezed,
    Object? unit = null,
    Object? recordedAt = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$MetricRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      valueExtra: freezed == valueExtra
          ? _value._valueExtra
          : valueExtra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricRecordImpl implements _MetricRecord {
  const _$MetricRecordImpl(
      {required this.id,
      required this.memberId,
      required this.metricType,
      required this.value,
      final Map<String, dynamic>? valueExtra,
      required this.unit,
      required this.recordedAt,
      this.note,
      required this.createdAt})
      : _valueExtra = valueExtra;

  factory _$MetricRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String memberId;
  @override
  final String metricType;
  @override
  final double value;
  final Map<String, dynamic>? _valueExtra;
  @override
  Map<String, dynamic>? get valueExtra {
    final value = _valueExtra;
    if (value == null) return null;
    if (_valueExtra is EqualUnmodifiableMapView) return _valueExtra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String unit;
  @override
  final DateTime recordedAt;
  @override
  final String? note;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MetricRecord(id: $id, memberId: $memberId, metricType: $metricType, value: $value, valueExtra: $valueExtra, unit: $unit, recordedAt: $recordedAt, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.value, value) || other.value == value) &&
            const DeepCollectionEquality()
                .equals(other._valueExtra, _valueExtra) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      memberId,
      metricType,
      value,
      const DeepCollectionEquality().hash(_valueExtra),
      unit,
      recordedAt,
      note,
      createdAt);

  /// Create a copy of MetricRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetricRecordImplCopyWith<_$MetricRecordImpl> get copyWith =>
      __$$MetricRecordImplCopyWithImpl<_$MetricRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetricRecordImplToJson(
      this,
    );
  }
}

abstract class _MetricRecord implements MetricRecord {
  const factory _MetricRecord(
      {required final String id,
      required final String memberId,
      required final String metricType,
      required final double value,
      final Map<String, dynamic>? valueExtra,
      required final String unit,
      required final DateTime recordedAt,
      final String? note,
      required final DateTime createdAt}) = _$MetricRecordImpl;

  factory _MetricRecord.fromJson(Map<String, dynamic> json) =
      _$MetricRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get memberId;
  @override
  String get metricType;
  @override
  double get value;
  @override
  Map<String, dynamic>? get valueExtra;
  @override
  String get unit;
  @override
  DateTime get recordedAt;
  @override
  String? get note;
  @override
  DateTime get createdAt;

  /// Create a copy of MetricRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetricRecordImplCopyWith<_$MetricRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MetricRecordCreate _$MetricRecordCreateFromJson(Map<String, dynamic> json) {
  return _MetricRecordCreate.fromJson(json);
}

/// @nodoc
mixin _$MetricRecordCreate {
  String get memberId => throw _privateConstructorUsedError;
  String get metricType => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  Map<String, dynamic>? get valueExtra => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this MetricRecordCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MetricRecordCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MetricRecordCreateCopyWith<MetricRecordCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetricRecordCreateCopyWith<$Res> {
  factory $MetricRecordCreateCopyWith(
          MetricRecordCreate value, $Res Function(MetricRecordCreate) then) =
      _$MetricRecordCreateCopyWithImpl<$Res, MetricRecordCreate>;
  @useResult
  $Res call(
      {String memberId,
      String metricType,
      double value,
      Map<String, dynamic>? valueExtra,
      String unit,
      DateTime recordedAt,
      String? note});
}

/// @nodoc
class _$MetricRecordCreateCopyWithImpl<$Res, $Val extends MetricRecordCreate>
    implements $MetricRecordCreateCopyWith<$Res> {
  _$MetricRecordCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MetricRecordCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? metricType = null,
    Object? value = null,
    Object? valueExtra = freezed,
    Object? unit = null,
    Object? recordedAt = null,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      valueExtra: freezed == valueExtra
          ? _value.valueExtra
          : valueExtra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetricRecordCreateImplCopyWith<$Res>
    implements $MetricRecordCreateCopyWith<$Res> {
  factory _$$MetricRecordCreateImplCopyWith(_$MetricRecordCreateImpl value,
          $Res Function(_$MetricRecordCreateImpl) then) =
      __$$MetricRecordCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String memberId,
      String metricType,
      double value,
      Map<String, dynamic>? valueExtra,
      String unit,
      DateTime recordedAt,
      String? note});
}

/// @nodoc
class __$$MetricRecordCreateImplCopyWithImpl<$Res>
    extends _$MetricRecordCreateCopyWithImpl<$Res, _$MetricRecordCreateImpl>
    implements _$$MetricRecordCreateImplCopyWith<$Res> {
  __$$MetricRecordCreateImplCopyWithImpl(_$MetricRecordCreateImpl _value,
      $Res Function(_$MetricRecordCreateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MetricRecordCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? metricType = null,
    Object? value = null,
    Object? valueExtra = freezed,
    Object? unit = null,
    Object? recordedAt = null,
    Object? note = freezed,
  }) {
    return _then(_$MetricRecordCreateImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      valueExtra: freezed == valueExtra
          ? _value._valueExtra
          : valueExtra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetricRecordCreateImpl implements _MetricRecordCreate {
  const _$MetricRecordCreateImpl(
      {required this.memberId,
      required this.metricType,
      required this.value,
      final Map<String, dynamic>? valueExtra,
      required this.unit,
      required this.recordedAt,
      this.note})
      : _valueExtra = valueExtra;

  factory _$MetricRecordCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetricRecordCreateImplFromJson(json);

  @override
  final String memberId;
  @override
  final String metricType;
  @override
  final double value;
  final Map<String, dynamic>? _valueExtra;
  @override
  Map<String, dynamic>? get valueExtra {
    final value = _valueExtra;
    if (value == null) return null;
    if (_valueExtra is EqualUnmodifiableMapView) return _valueExtra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String unit;
  @override
  final DateTime recordedAt;
  @override
  final String? note;

  @override
  String toString() {
    return 'MetricRecordCreate(memberId: $memberId, metricType: $metricType, value: $value, valueExtra: $valueExtra, unit: $unit, recordedAt: $recordedAt, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetricRecordCreateImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.value, value) || other.value == value) &&
            const DeepCollectionEquality()
                .equals(other._valueExtra, _valueExtra) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, memberId, metricType, value,
      const DeepCollectionEquality().hash(_valueExtra), unit, recordedAt, note);

  /// Create a copy of MetricRecordCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MetricRecordCreateImplCopyWith<_$MetricRecordCreateImpl> get copyWith =>
      __$$MetricRecordCreateImplCopyWithImpl<_$MetricRecordCreateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetricRecordCreateImplToJson(
      this,
    );
  }
}

abstract class _MetricRecordCreate implements MetricRecordCreate {
  const factory _MetricRecordCreate(
      {required final String memberId,
      required final String metricType,
      required final double value,
      final Map<String, dynamic>? valueExtra,
      required final String unit,
      required final DateTime recordedAt,
      final String? note}) = _$MetricRecordCreateImpl;

  factory _MetricRecordCreate.fromJson(Map<String, dynamic> json) =
      _$MetricRecordCreateImpl.fromJson;

  @override
  String get memberId;
  @override
  String get metricType;
  @override
  double get value;
  @override
  Map<String, dynamic>? get valueExtra;
  @override
  String get unit;
  @override
  DateTime get recordedAt;
  @override
  String? get note;

  /// Create a copy of MetricRecordCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MetricRecordCreateImplCopyWith<_$MetricRecordCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
