// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthEvent _$HealthEventFromJson(Map<String, dynamic> json) {
  return _HealthEvent.fromJson(json);
}

/// @nodoc
mixin _$HealthEvent {
  String get id => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  Map<String, dynamic>? get repeatRule => throw _privateConstructorUsedError;
  List<int>? get notifyOffsets => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get sourceType => throw _privateConstructorUsedError;
  String? get sourceText => throw _privateConstructorUsedError;
  double? get aiConfidence => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthEventCopyWith<HealthEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthEventCopyWith<$Res> {
  factory $HealthEventCopyWith(
          HealthEvent value, $Res Function(HealthEvent) then) =
      _$HealthEventCopyWithImpl<$Res, HealthEvent>;
  @useResult
  $Res call(
      {String id,
      String memberId,
      String title,
      String? description,
      String eventType,
      DateTime scheduledAt,
      bool isAllDay,
      Map<String, dynamic>? repeatRule,
      List<int>? notifyOffsets,
      String status,
      String sourceType,
      String? sourceText,
      double? aiConfidence,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? completedAt});
}

/// @nodoc
class _$HealthEventCopyWithImpl<$Res, $Val extends HealthEvent>
    implements $HealthEventCopyWith<$Res> {
  _$HealthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? title = null,
    Object? description = freezed,
    Object? eventType = null,
    Object? scheduledAt = null,
    Object? isAllDay = null,
    Object? repeatRule = freezed,
    Object? notifyOffsets = freezed,
    Object? status = null,
    Object? sourceType = null,
    Object? sourceText = freezed,
    Object? aiConfidence = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
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
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatRule: freezed == repeatRule
          ? _value.repeatRule
          : repeatRule // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsets: freezed == notifyOffsets
          ? _value.notifyOffsets
          : notifyOffsets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: freezed == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidence: freezed == aiConfidence
          ? _value.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthEventImplCopyWith<$Res>
    implements $HealthEventCopyWith<$Res> {
  factory _$$HealthEventImplCopyWith(
          _$HealthEventImpl value, $Res Function(_$HealthEventImpl) then) =
      __$$HealthEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String memberId,
      String title,
      String? description,
      String eventType,
      DateTime scheduledAt,
      bool isAllDay,
      Map<String, dynamic>? repeatRule,
      List<int>? notifyOffsets,
      String status,
      String sourceType,
      String? sourceText,
      double? aiConfidence,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? completedAt});
}

/// @nodoc
class __$$HealthEventImplCopyWithImpl<$Res>
    extends _$HealthEventCopyWithImpl<$Res, _$HealthEventImpl>
    implements _$$HealthEventImplCopyWith<$Res> {
  __$$HealthEventImplCopyWithImpl(
      _$HealthEventImpl _value, $Res Function(_$HealthEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? title = null,
    Object? description = freezed,
    Object? eventType = null,
    Object? scheduledAt = null,
    Object? isAllDay = null,
    Object? repeatRule = freezed,
    Object? notifyOffsets = freezed,
    Object? status = null,
    Object? sourceType = null,
    Object? sourceText = freezed,
    Object? aiConfidence = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$HealthEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatRule: freezed == repeatRule
          ? _value._repeatRule
          : repeatRule // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsets: freezed == notifyOffsets
          ? _value._notifyOffsets
          : notifyOffsets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: freezed == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidence: freezed == aiConfidence
          ? _value.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthEventImpl implements _HealthEvent {
  const _$HealthEventImpl(
      {required this.id,
      required this.memberId,
      required this.title,
      this.description,
      required this.eventType,
      required this.scheduledAt,
      this.isAllDay = false,
      final Map<String, dynamic>? repeatRule,
      final List<int>? notifyOffsets,
      this.status = 'pending',
      required this.sourceType,
      this.sourceText,
      this.aiConfidence,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt})
      : _repeatRule = repeatRule,
        _notifyOffsets = notifyOffsets;

  factory _$HealthEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthEventImplFromJson(json);

  @override
  final String id;
  @override
  final String memberId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String eventType;
  @override
  final DateTime scheduledAt;
  @override
  @JsonKey()
  final bool isAllDay;
  final Map<String, dynamic>? _repeatRule;
  @override
  Map<String, dynamic>? get repeatRule {
    final value = _repeatRule;
    if (value == null) return null;
    if (_repeatRule is EqualUnmodifiableMapView) return _repeatRule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<int>? _notifyOffsets;
  @override
  List<int>? get notifyOffsets {
    final value = _notifyOffsets;
    if (value == null) return null;
    if (_notifyOffsets is EqualUnmodifiableListView) return _notifyOffsets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final String status;
  @override
  final String sourceType;
  @override
  final String? sourceText;
  @override
  final double? aiConfidence;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'HealthEvent(id: $id, memberId: $memberId, title: $title, description: $description, eventType: $eventType, scheduledAt: $scheduledAt, isAllDay: $isAllDay, repeatRule: $repeatRule, notifyOffsets: $notifyOffsets, status: $status, sourceType: $sourceType, sourceText: $sourceText, aiConfidence: $aiConfidence, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            const DeepCollectionEquality()
                .equals(other._repeatRule, _repeatRule) &&
            const DeepCollectionEquality()
                .equals(other._notifyOffsets, _notifyOffsets) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText) &&
            (identical(other.aiConfidence, aiConfidence) ||
                other.aiConfidence == aiConfidence) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      memberId,
      title,
      description,
      eventType,
      scheduledAt,
      isAllDay,
      const DeepCollectionEquality().hash(_repeatRule),
      const DeepCollectionEquality().hash(_notifyOffsets),
      status,
      sourceType,
      sourceText,
      aiConfidence,
      createdAt,
      updatedAt,
      completedAt);

  /// Create a copy of HealthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthEventImplCopyWith<_$HealthEventImpl> get copyWith =>
      __$$HealthEventImplCopyWithImpl<_$HealthEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthEventImplToJson(
      this,
    );
  }
}

abstract class _HealthEvent implements HealthEvent {
  const factory _HealthEvent(
      {required final String id,
      required final String memberId,
      required final String title,
      final String? description,
      required final String eventType,
      required final DateTime scheduledAt,
      final bool isAllDay,
      final Map<String, dynamic>? repeatRule,
      final List<int>? notifyOffsets,
      final String status,
      required final String sourceType,
      final String? sourceText,
      final double? aiConfidence,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? completedAt}) = _$HealthEventImpl;

  factory _HealthEvent.fromJson(Map<String, dynamic> json) =
      _$HealthEventImpl.fromJson;

  @override
  String get id;
  @override
  String get memberId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get eventType;
  @override
  DateTime get scheduledAt;
  @override
  bool get isAllDay;
  @override
  Map<String, dynamic>? get repeatRule;
  @override
  List<int>? get notifyOffsets;
  @override
  String get status;
  @override
  String get sourceType;
  @override
  String? get sourceText;
  @override
  double? get aiConfidence;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of HealthEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthEventImplCopyWith<_$HealthEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventCreate _$EventCreateFromJson(Map<String, dynamic> json) {
  return _EventCreate.fromJson(json);
}

/// @nodoc
mixin _$EventCreate {
  String get memberId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  Map<String, dynamic>? get repeatRule => throw _privateConstructorUsedError;
  List<int>? get notifyOffsets => throw _privateConstructorUsedError;
  String get sourceType => throw _privateConstructorUsedError;
  String? get sourceText => throw _privateConstructorUsedError;
  double? get aiConfidence => throw _privateConstructorUsedError;

  /// Serializes this EventCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCreateCopyWith<EventCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCreateCopyWith<$Res> {
  factory $EventCreateCopyWith(
          EventCreate value, $Res Function(EventCreate) then) =
      _$EventCreateCopyWithImpl<$Res, EventCreate>;
  @useResult
  $Res call(
      {String memberId,
      String title,
      String? description,
      String eventType,
      DateTime scheduledAt,
      bool isAllDay,
      Map<String, dynamic>? repeatRule,
      List<int>? notifyOffsets,
      String sourceType,
      String? sourceText,
      double? aiConfidence});
}

/// @nodoc
class _$EventCreateCopyWithImpl<$Res, $Val extends EventCreate>
    implements $EventCreateCopyWith<$Res> {
  _$EventCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? title = null,
    Object? description = freezed,
    Object? eventType = null,
    Object? scheduledAt = null,
    Object? isAllDay = null,
    Object? repeatRule = freezed,
    Object? notifyOffsets = freezed,
    Object? sourceType = null,
    Object? sourceText = freezed,
    Object? aiConfidence = freezed,
  }) {
    return _then(_value.copyWith(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatRule: freezed == repeatRule
          ? _value.repeatRule
          : repeatRule // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsets: freezed == notifyOffsets
          ? _value.notifyOffsets
          : notifyOffsets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: freezed == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidence: freezed == aiConfidence
          ? _value.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventCreateImplCopyWith<$Res>
    implements $EventCreateCopyWith<$Res> {
  factory _$$EventCreateImplCopyWith(
          _$EventCreateImpl value, $Res Function(_$EventCreateImpl) then) =
      __$$EventCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String memberId,
      String title,
      String? description,
      String eventType,
      DateTime scheduledAt,
      bool isAllDay,
      Map<String, dynamic>? repeatRule,
      List<int>? notifyOffsets,
      String sourceType,
      String? sourceText,
      double? aiConfidence});
}

/// @nodoc
class __$$EventCreateImplCopyWithImpl<$Res>
    extends _$EventCreateCopyWithImpl<$Res, _$EventCreateImpl>
    implements _$$EventCreateImplCopyWith<$Res> {
  __$$EventCreateImplCopyWithImpl(
      _$EventCreateImpl _value, $Res Function(_$EventCreateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? title = null,
    Object? description = freezed,
    Object? eventType = null,
    Object? scheduledAt = null,
    Object? isAllDay = null,
    Object? repeatRule = freezed,
    Object? notifyOffsets = freezed,
    Object? sourceType = null,
    Object? sourceText = freezed,
    Object? aiConfidence = freezed,
  }) {
    return _then(_$EventCreateImpl(
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAllDay: null == isAllDay
          ? _value.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatRule: freezed == repeatRule
          ? _value._repeatRule
          : repeatRule // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsets: freezed == notifyOffsets
          ? _value._notifyOffsets
          : notifyOffsets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      sourceType: null == sourceType
          ? _value.sourceType
          : sourceType // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: freezed == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidence: freezed == aiConfidence
          ? _value.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventCreateImpl implements _EventCreate {
  const _$EventCreateImpl(
      {required this.memberId,
      required this.title,
      this.description,
      required this.eventType,
      required this.scheduledAt,
      this.isAllDay = false,
      final Map<String, dynamic>? repeatRule,
      final List<int>? notifyOffsets,
      this.sourceType = 'manual',
      this.sourceText,
      this.aiConfidence})
      : _repeatRule = repeatRule,
        _notifyOffsets = notifyOffsets;

  factory _$EventCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventCreateImplFromJson(json);

  @override
  final String memberId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String eventType;
  @override
  final DateTime scheduledAt;
  @override
  @JsonKey()
  final bool isAllDay;
  final Map<String, dynamic>? _repeatRule;
  @override
  Map<String, dynamic>? get repeatRule {
    final value = _repeatRule;
    if (value == null) return null;
    if (_repeatRule is EqualUnmodifiableMapView) return _repeatRule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<int>? _notifyOffsets;
  @override
  List<int>? get notifyOffsets {
    final value = _notifyOffsets;
    if (value == null) return null;
    if (_notifyOffsets is EqualUnmodifiableListView) return _notifyOffsets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final String sourceType;
  @override
  final String? sourceText;
  @override
  final double? aiConfidence;

  @override
  String toString() {
    return 'EventCreate(memberId: $memberId, title: $title, description: $description, eventType: $eventType, scheduledAt: $scheduledAt, isAllDay: $isAllDay, repeatRule: $repeatRule, notifyOffsets: $notifyOffsets, sourceType: $sourceType, sourceText: $sourceText, aiConfidence: $aiConfidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventCreateImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            const DeepCollectionEquality()
                .equals(other._repeatRule, _repeatRule) &&
            const DeepCollectionEquality()
                .equals(other._notifyOffsets, _notifyOffsets) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText) &&
            (identical(other.aiConfidence, aiConfidence) ||
                other.aiConfidence == aiConfidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      memberId,
      title,
      description,
      eventType,
      scheduledAt,
      isAllDay,
      const DeepCollectionEquality().hash(_repeatRule),
      const DeepCollectionEquality().hash(_notifyOffsets),
      sourceType,
      sourceText,
      aiConfidence);

  /// Create a copy of EventCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventCreateImplCopyWith<_$EventCreateImpl> get copyWith =>
      __$$EventCreateImplCopyWithImpl<_$EventCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventCreateImplToJson(
      this,
    );
  }
}

abstract class _EventCreate implements EventCreate {
  const factory _EventCreate(
      {required final String memberId,
      required final String title,
      final String? description,
      required final String eventType,
      required final DateTime scheduledAt,
      final bool isAllDay,
      final Map<String, dynamic>? repeatRule,
      final List<int>? notifyOffsets,
      final String sourceType,
      final String? sourceText,
      final double? aiConfidence}) = _$EventCreateImpl;

  factory _EventCreate.fromJson(Map<String, dynamic> json) =
      _$EventCreateImpl.fromJson;

  @override
  String get memberId;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get eventType;
  @override
  DateTime get scheduledAt;
  @override
  bool get isAllDay;
  @override
  Map<String, dynamic>? get repeatRule;
  @override
  List<int>? get notifyOffsets;
  @override
  String get sourceType;
  @override
  String? get sourceText;
  @override
  double? get aiConfidence;

  /// Create a copy of EventCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventCreateImplCopyWith<_$EventCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
