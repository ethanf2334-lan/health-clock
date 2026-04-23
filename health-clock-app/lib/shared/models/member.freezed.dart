// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Member _$MemberFromJson(Map<String, dynamic> json) {
  return _Member.fromJson(json);
}

/// @nodoc
mixin _$Member {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get relation => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  double? get heightCm => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  List<String>? get chronicConditions => throw _privateConstructorUsedError;
  List<String>? get allergies => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberCopyWith<Member> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) then) =
      _$MemberCopyWithImpl<$Res, Member>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? relation,
      String? gender,
      DateTime? birthDate,
      double? heightCm,
      double? weightKg,
      String? bloodType,
      List<String>? chronicConditions,
      List<String>? allergies,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$MemberCopyWithImpl<$Res, $Val extends Member>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? relation = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bloodType = freezed,
    Object? chronicConditions = freezed,
    Object? allergies = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      relation: freezed == relation
          ? _value.relation
          : relation // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      chronicConditions: freezed == chronicConditions
          ? _value.chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allergies: freezed == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberImplCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$$MemberImplCopyWith(
          _$MemberImpl value, $Res Function(_$MemberImpl) then) =
      __$$MemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? relation,
      String? gender,
      DateTime? birthDate,
      double? heightCm,
      double? weightKg,
      String? bloodType,
      List<String>? chronicConditions,
      List<String>? allergies,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$MemberImplCopyWithImpl<$Res>
    extends _$MemberCopyWithImpl<$Res, _$MemberImpl>
    implements _$$MemberImplCopyWith<$Res> {
  __$$MemberImplCopyWithImpl(
      _$MemberImpl _value, $Res Function(_$MemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? relation = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bloodType = freezed,
    Object? chronicConditions = freezed,
    Object? allergies = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      relation: freezed == relation
          ? _value.relation
          : relation // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      chronicConditions: freezed == chronicConditions
          ? _value._chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allergies: freezed == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberImpl implements _Member {
  const _$MemberImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.relation,
      this.gender,
      this.birthDate,
      this.heightCm,
      this.weightKg,
      this.bloodType,
      final List<String>? chronicConditions,
      final List<String>? allergies,
      this.notes,
      required this.createdAt,
      required this.updatedAt})
      : _chronicConditions = chronicConditions,
        _allergies = allergies;

  factory _$MemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? relation;
  @override
  final String? gender;
  @override
  final DateTime? birthDate;
  @override
  final double? heightCm;
  @override
  final double? weightKg;
  @override
  final String? bloodType;
  final List<String>? _chronicConditions;
  @override
  List<String>? get chronicConditions {
    final value = _chronicConditions;
    if (value == null) return null;
    if (_chronicConditions is EqualUnmodifiableListView)
      return _chronicConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _allergies;
  @override
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Member(id: $id, userId: $userId, name: $name, relation: $relation, gender: $gender, birthDate: $birthDate, heightCm: $heightCm, weightKg: $weightKg, bloodType: $bloodType, chronicConditions: $chronicConditions, allergies: $allergies, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.relation, relation) ||
                other.relation == relation) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            const DeepCollectionEquality()
                .equals(other._chronicConditions, _chronicConditions) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      relation,
      gender,
      birthDate,
      heightCm,
      weightKg,
      bloodType,
      const DeepCollectionEquality().hash(_chronicConditions),
      const DeepCollectionEquality().hash(_allergies),
      notes,
      createdAt,
      updatedAt);

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      __$$MemberImplCopyWithImpl<_$MemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberImplToJson(
      this,
    );
  }
}

abstract class _Member implements Member {
  const factory _Member(
      {required final String id,
      required final String userId,
      required final String name,
      final String? relation,
      final String? gender,
      final DateTime? birthDate,
      final double? heightCm,
      final double? weightKg,
      final String? bloodType,
      final List<String>? chronicConditions,
      final List<String>? allergies,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$MemberImpl;

  factory _Member.fromJson(Map<String, dynamic> json) = _$MemberImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get relation;
  @override
  String? get gender;
  @override
  DateTime? get birthDate;
  @override
  double? get heightCm;
  @override
  double? get weightKg;
  @override
  String? get bloodType;
  @override
  List<String>? get chronicConditions;
  @override
  List<String>? get allergies;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberImplCopyWith<_$MemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemberCreate _$MemberCreateFromJson(Map<String, dynamic> json) {
  return _MemberCreate.fromJson(json);
}

/// @nodoc
mixin _$MemberCreate {
  String get name => throw _privateConstructorUsedError;
  String? get relation => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  double? get heightCm => throw _privateConstructorUsedError;
  double? get weightKg => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  List<String>? get chronicConditions => throw _privateConstructorUsedError;
  List<String>? get allergies => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this MemberCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemberCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberCreateCopyWith<MemberCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberCreateCopyWith<$Res> {
  factory $MemberCreateCopyWith(
          MemberCreate value, $Res Function(MemberCreate) then) =
      _$MemberCreateCopyWithImpl<$Res, MemberCreate>;
  @useResult
  $Res call(
      {String name,
      String? relation,
      String? gender,
      DateTime? birthDate,
      double? heightCm,
      double? weightKg,
      String? bloodType,
      List<String>? chronicConditions,
      List<String>? allergies,
      String? notes});
}

/// @nodoc
class _$MemberCreateCopyWithImpl<$Res, $Val extends MemberCreate>
    implements $MemberCreateCopyWith<$Res> {
  _$MemberCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? relation = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bloodType = freezed,
    Object? chronicConditions = freezed,
    Object? allergies = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      relation: freezed == relation
          ? _value.relation
          : relation // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      chronicConditions: freezed == chronicConditions
          ? _value.chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allergies: freezed == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberCreateImplCopyWith<$Res>
    implements $MemberCreateCopyWith<$Res> {
  factory _$$MemberCreateImplCopyWith(
          _$MemberCreateImpl value, $Res Function(_$MemberCreateImpl) then) =
      __$$MemberCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? relation,
      String? gender,
      DateTime? birthDate,
      double? heightCm,
      double? weightKg,
      String? bloodType,
      List<String>? chronicConditions,
      List<String>? allergies,
      String? notes});
}

/// @nodoc
class __$$MemberCreateImplCopyWithImpl<$Res>
    extends _$MemberCreateCopyWithImpl<$Res, _$MemberCreateImpl>
    implements _$$MemberCreateImplCopyWith<$Res> {
  __$$MemberCreateImplCopyWithImpl(
      _$MemberCreateImpl _value, $Res Function(_$MemberCreateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MemberCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? relation = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? bloodType = freezed,
    Object? chronicConditions = freezed,
    Object? allergies = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$MemberCreateImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      relation: freezed == relation
          ? _value.relation
          : relation // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      chronicConditions: freezed == chronicConditions
          ? _value._chronicConditions
          : chronicConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allergies: freezed == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberCreateImpl implements _MemberCreate {
  const _$MemberCreateImpl(
      {required this.name,
      this.relation,
      this.gender,
      this.birthDate,
      this.heightCm,
      this.weightKg,
      this.bloodType,
      final List<String>? chronicConditions,
      final List<String>? allergies,
      this.notes})
      : _chronicConditions = chronicConditions,
        _allergies = allergies;

  factory _$MemberCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberCreateImplFromJson(json);

  @override
  final String name;
  @override
  final String? relation;
  @override
  final String? gender;
  @override
  final DateTime? birthDate;
  @override
  final double? heightCm;
  @override
  final double? weightKg;
  @override
  final String? bloodType;
  final List<String>? _chronicConditions;
  @override
  List<String>? get chronicConditions {
    final value = _chronicConditions;
    if (value == null) return null;
    if (_chronicConditions is EqualUnmodifiableListView)
      return _chronicConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _allergies;
  @override
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;

  @override
  String toString() {
    return 'MemberCreate(name: $name, relation: $relation, gender: $gender, birthDate: $birthDate, heightCm: $heightCm, weightKg: $weightKg, bloodType: $bloodType, chronicConditions: $chronicConditions, allergies: $allergies, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberCreateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.relation, relation) ||
                other.relation == relation) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            const DeepCollectionEquality()
                .equals(other._chronicConditions, _chronicConditions) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      relation,
      gender,
      birthDate,
      heightCm,
      weightKg,
      bloodType,
      const DeepCollectionEquality().hash(_chronicConditions),
      const DeepCollectionEquality().hash(_allergies),
      notes);

  /// Create a copy of MemberCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberCreateImplCopyWith<_$MemberCreateImpl> get copyWith =>
      __$$MemberCreateImplCopyWithImpl<_$MemberCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberCreateImplToJson(
      this,
    );
  }
}

abstract class _MemberCreate implements MemberCreate {
  const factory _MemberCreate(
      {required final String name,
      final String? relation,
      final String? gender,
      final DateTime? birthDate,
      final double? heightCm,
      final double? weightKg,
      final String? bloodType,
      final List<String>? chronicConditions,
      final List<String>? allergies,
      final String? notes}) = _$MemberCreateImpl;

  factory _MemberCreate.fromJson(Map<String, dynamic> json) =
      _$MemberCreateImpl.fromJson;

  @override
  String get name;
  @override
  String? get relation;
  @override
  String? get gender;
  @override
  DateTime? get birthDate;
  @override
  double? get heightCm;
  @override
  double? get weightKg;
  @override
  String? get bloodType;
  @override
  List<String>? get chronicConditions;
  @override
  List<String>? get allergies;
  @override
  String? get notes;

  /// Create a copy of MemberCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberCreateImplCopyWith<_$MemberCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
