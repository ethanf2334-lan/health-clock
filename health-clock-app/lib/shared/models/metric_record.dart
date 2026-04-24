import 'package:freezed_annotation/freezed_annotation.dart';

part 'metric_record.freezed.dart';
part 'metric_record.g.dart';

@freezed
class MetricRecord with _$MetricRecord {
  const factory MetricRecord({
    required String id,
    required String memberId,
    required String metricType,
    required double value,
    Map<String, dynamic>? valueExtra,
    required String unit,
    required DateTime recordedAt,
    String? note,
    required DateTime createdAt,
  }) = _MetricRecord;

  factory MetricRecord.fromJson(Map<String, dynamic> json) =>
      _$MetricRecordFromJson(json);
}

@freezed
class MetricRecordCreate with _$MetricRecordCreate {
  const factory MetricRecordCreate({
    required String memberId,
    required String metricType,
    required double value,
    Map<String, dynamic>? valueExtra,
    required String unit,
    required DateTime recordedAt,
    String? note,
  }) = _MetricRecordCreate;

  factory MetricRecordCreate.fromJson(Map<String, dynamic> json) =>
      _$MetricRecordCreateFromJson(json);
}
