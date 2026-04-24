import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/models/metric_record.dart';

part 'metric_repository.g.dart';

@riverpod
MetricRepository metricRepository(MetricRepositoryRef ref) {
  return MetricRepository(ref.watch(dioProvider));
}

Map<String, dynamic> _normalizeMetric(Map<String, dynamic> j) => {
      'id': j['id'],
      'memberId': j['member_id'] ?? j['memberId'],
      'metricType': j['metric_type'] ?? j['metricType'],
      'value': j['value'],
      'valueExtra': j['value_extra'] ?? j['valueExtra'],
      'unit': j['unit'],
      'recordedAt': j['recorded_at'] ?? j['recordedAt'],
      'note': j['note'],
      'createdAt': j['created_at'] ?? j['createdAt'],
    };

class MetricRepository {
  final Dio _dio;
  MetricRepository(this._dio);

  Future<List<MetricRecord>> listMetrics({
    String? memberId,
    String? metricType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final qp = <String, dynamic>{};
    if (memberId != null) qp['member_id'] = memberId;
    if (metricType != null) qp['metric_type'] = metricType;
    if (startDate != null) qp['start_date'] = startDate.toIso8601String();
    if (endDate != null) qp['end_date'] = endDate.toIso8601String();

    final resp = await _dio.get('/metrics', queryParameters: qp);
    final list = resp.data['data'] as List;
    return list
        .map((e) => MetricRecord.fromJson(_normalizeMetric(e as Map<String, dynamic>)))
        .toList();
  }

  Future<MetricRecord> createMetric(MetricRecordCreate data) async {
    final resp = await _dio.post('/metrics', data: {
      'member_id': data.memberId,
      'metric_type': data.metricType,
      'value': data.value,
      if (data.valueExtra != null) 'value_extra': data.valueExtra,
      'unit': data.unit,
      'recorded_at': data.recordedAt.toIso8601String(),
      if (data.note != null) 'note': data.note,
    });
    return MetricRecord.fromJson(_normalizeMetric(resp.data['data'] as Map<String, dynamic>));
  }

  Future<void> deleteMetric(String id) async {
    await _dio.delete('/metrics/$id');
  }
}
