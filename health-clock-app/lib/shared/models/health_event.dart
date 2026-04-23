import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_event.freezed.dart';
part 'health_event.g.dart';

@freezed
class HealthEvent with _$HealthEvent {
  const factory HealthEvent({
    required String id,
    required String memberId,
    required String title,
    String? description,
    required String eventType,
    required DateTime scheduledAt,
    @Default(false) bool isAllDay,
    Map<String, dynamic>? repeatRule,
    List<int>? notifyOffsets,
    @Default('pending') String status,
    required String sourceType,
    String? sourceText,
    double? aiConfidence,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) = _HealthEvent;

  factory HealthEvent.fromJson(Map<String, dynamic> json) =>
      _$HealthEventFromJson(json);
}

@freezed
class EventCreate with _$EventCreate {
  const factory EventCreate({
    required String memberId,
    required String title,
    String? description,
    required String eventType,
    required DateTime scheduledAt,
    @Default(false) bool isAllDay,
    Map<String, dynamic>? repeatRule,
    List<int>? notifyOffsets,
    @Default('manual') String sourceType,
    String? sourceText,
    double? aiConfidence,
  }) = _EventCreate;

  factory EventCreate.fromJson(Map<String, dynamic> json) =>
      _$EventCreateFromJson(json);
}
