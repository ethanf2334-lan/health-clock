// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetricRecordImpl _$$MetricRecordImplFromJson(Map<String, dynamic> json) =>
    _$MetricRecordImpl(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      metricType: json['metricType'] as String,
      value: (json['value'] as num).toDouble(),
      valueExtra: json['valueExtra'] as Map<String, dynamic>?,
      unit: json['unit'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MetricRecordImplToJson(_$MetricRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'metricType': instance.metricType,
      'value': instance.value,
      'valueExtra': instance.valueExtra,
      'unit': instance.unit,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$MetricRecordCreateImpl _$$MetricRecordCreateImplFromJson(
        Map<String, dynamic> json) =>
    _$MetricRecordCreateImpl(
      memberId: json['memberId'] as String,
      metricType: json['metricType'] as String,
      value: (json['value'] as num).toDouble(),
      valueExtra: json['valueExtra'] as Map<String, dynamic>?,
      unit: json['unit'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$MetricRecordCreateImplToJson(
        _$MetricRecordCreateImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'metricType': instance.metricType,
      'value': instance.value,
      'valueExtra': instance.valueExtra,
      'unit': instance.unit,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'note': instance.note,
    };
