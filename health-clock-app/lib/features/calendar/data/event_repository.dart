import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/models/health_event.dart';

part 'event_repository.g.dart';

@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepository(ref.watch(dioProvider));
}

Map<String, dynamic> _normalizeEvent(Map<String, dynamic> j) => {
      'id': j['id'],
      'memberId': j['member_id'] ?? j['memberId'],
      'title': j['title'],
      'description': j['description'],
      'eventType': j['event_type'] ?? j['eventType'],
      'scheduledAt': j['scheduled_at'] ?? j['scheduledAt'],
      'isAllDay': j['is_all_day'] ?? j['isAllDay'] ?? false,
      'repeatRule': j['repeat_rule'] ?? j['repeatRule'],
      'notifyOffsets': j['notify_offsets'] ?? j['notifyOffsets'],
      'status': j['status'] ?? 'pending',
      'sourceType': j['source_type'] ?? j['sourceType'] ?? 'manual',
      'sourceText': j['source_text'] ?? j['sourceText'],
      'aiConfidence': j['ai_confidence'] ?? j['aiConfidence'],
      'createdAt': j['created_at'] ?? j['createdAt'],
      'updatedAt': j['updated_at'] ?? j['updatedAt'],
      'completedAt': j['completed_at'] ?? j['completedAt'],
    };

class EventRepository {
  final Dio _dio;

  EventRepository(this._dio);

  Future<List<HealthEvent>> getEvents({
    String? memberId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? eventType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (memberId != null) queryParams['member_id'] = memberId;
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (status != null) queryParams['status'] = status;
    if (eventType != null) queryParams['event_type'] = eventType;

    final response = await _dio.get(
      '/events',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data
        .map(
          (j) =>
              HealthEvent.fromJson(_normalizeEvent(j as Map<String, dynamic>)),
        )
        .toList();
  }

  Future<HealthEvent> getEvent(String id) async {
    final response = await _dio.get('/events/$id');
    return HealthEvent.fromJson(
      _normalizeEvent(response.data['data'] as Map<String, dynamic>),
    );
  }

  Future<HealthEvent> createEvent(EventCreate event) async {
    final body = <String, dynamic>{
      'member_id': event.memberId,
      'title': event.title,
      if (event.description != null) 'description': event.description,
      'event_type': event.eventType,
      'scheduled_at': event.scheduledAt.toIso8601String(),
      'is_all_day': event.isAllDay,
      if (event.repeatRule != null) 'repeat_rule': event.repeatRule,
      if (event.notifyOffsets != null) 'notify_offsets': event.notifyOffsets,
      'source_type': event.sourceType,
      if (event.sourceText != null) 'source_text': event.sourceText,
      if (event.aiConfidence != null) 'ai_confidence': event.aiConfidence,
    };
    final response = await _dio.post('/events', data: body);
    return HealthEvent.fromJson(
      _normalizeEvent(response.data['data'] as Map<String, dynamic>),
    );
  }

  Future<HealthEvent> updateEvent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put('/events/$id', data: updates);
    return HealthEvent.fromJson(
      _normalizeEvent(response.data['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteEvent(String id) async {
    await _dio.delete('/events/$id');
  }

  Future<HealthEvent> completeEvent(String id) async {
    final response = await _dio.post('/events/$id/complete');
    return HealthEvent.fromJson(
      _normalizeEvent(response.data['data'] as Map<String, dynamic>),
    );
  }
}
