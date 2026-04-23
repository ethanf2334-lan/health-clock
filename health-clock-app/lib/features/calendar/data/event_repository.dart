import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/health_event.dart';
import '../services/api_client.dart';

part 'event_repository.g.dart';

@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepository(ref.watch(dioProvider));
}

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
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (status != null) queryParams['status'] = status;
    if (eventType != null) queryParams['event_type'] = eventType;

    final response = await _dio.get(
      '/events',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((json) => HealthEvent.fromJson(json)).toList();
  }

  Future<HealthEvent> getEvent(String id) async {
    final response = await _dio.get('/events/$id');
    return HealthEvent.fromJson(response.data['data']);
  }

  Future<HealthEvent> createEvent(EventCreate event) async {
    final response = await _dio.post(
      '/events',
      data: event.toJson(),
    );
    return HealthEvent.fromJson(response.data['data']);
  }

  Future<HealthEvent> updateEvent(String id, Map<String, dynamic> updates) async {
    final response = await _dio.put(
      '/events/$id',
      data: updates,
    );
    return HealthEvent.fromJson(response.data['data']);
  }

  Future<void> deleteEvent(String id) async {
    await _dio.delete('/events/$id');
  }

  Future<HealthEvent> completeEvent(String id) async {
    final response = await _dio.post('/events/$id/complete');
    return HealthEvent.fromJson(response.data['data']);
  }
}
