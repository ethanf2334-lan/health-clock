// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberImpl _$$MemberImplFromJson(Map<String, dynamic> json) => _$MemberImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MemberImplToJson(_$MemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'relation': instance.relation,
      'gender': instance.gender,
      'birthDate': instance.birthDate?.toIso8601String(),
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'bloodType': instance.bloodType,
      'chronicConditions': instance.chronicConditions,
      'allergies': instance.allergies,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$MemberCreateImpl _$$MemberCreateImplFromJson(Map<String, dynamic> json) =>
    _$MemberCreateImpl(
      name: json['name'] as String,
      relation: json['relation'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MemberCreateImplToJson(_$MemberCreateImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'relation': instance.relation,
      'gender': instance.gender,
      'birthDate': instance.birthDate?.toIso8601String(),
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
      'bloodType': instance.bloodType,
      'chronicConditions': instance.chronicConditions,
      'allergies': instance.allergies,
      'notes': instance.notes,
    };
