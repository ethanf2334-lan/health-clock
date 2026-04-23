// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthEventImpl _$$HealthEventImplFromJson(Map<String, dynamic> json) =>
    _$HealthEventImpl(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['eventType'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      repeatRule: json['repeatRule'] as Map<String, dynamic>?,
      notifyOffsets: (json['notifyOffsets'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      status: json['status'] as String? ?? 'pending',
      sourceType: json['sourceType'] as String,
      sourceText: json['sourceText'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$HealthEventImplToJson(_$HealthEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'title': instance.title,
      'description': instance.description,
      'eventType': instance.eventType,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'isAllDay': instance.isAllDay,
      'repeatRule': instance.repeatRule,
      'notifyOffsets': instance.notifyOffsets,
      'status': instance.status,
      'sourceType': instance.sourceType,
      'sourceText': instance.sourceText,
      'aiConfidence': instance.aiConfidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$EventCreateImpl _$$EventCreateImplFromJson(Map<String, dynamic> json) =>
    _$EventCreateImpl(
      memberId: json['memberId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['eventType'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      repeatRule: json['repeatRule'] as Map<String, dynamic>?,
      notifyOffsets: (json['notifyOffsets'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      sourceType: json['sourceType'] as String? ?? 'manual',
      sourceText: json['sourceText'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$EventCreateImplToJson(_$EventCreateImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'title': instance.title,
      'description': instance.description,
      'eventType': instance.eventType,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'isAllDay': instance.isAllDay,
      'repeatRule': instance.repeatRule,
      'notifyOffsets': instance.notifyOffsets,
      'sourceType': instance.sourceType,
      'sourceText': instance.sourceText,
      'aiConfidence': instance.aiConfidence,
    };
