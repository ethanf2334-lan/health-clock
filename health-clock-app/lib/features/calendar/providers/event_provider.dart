import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/health_event.dart';
import '../data/event_repository.dart';

part 'event_provider.g.dart';

class EventListFilter {
  final String? memberId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? eventType;

  const EventListFilter({
    this.memberId,
    this.startDate,
    this.endDate,
    this.status,
    this.eventType,
  });
}

@riverpod
class EventList extends _$EventList {
  EventListFilter _filter = const EventListFilter();

  @override
  Future<List<HealthEvent>> build() async {
    return ref.read(eventRepositoryProvider).getEvents(
          memberId: _filter.memberId,
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          status: _filter.status,
          eventType: _filter.eventType,
        );
  }

  Future<void> setFilter(EventListFilter filter) async {
    _filter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref.read(eventRepositoryProvider).getEvents(
            memberId: filter.memberId,
            startDate: filter.startDate,
            endDate: filter.endDate,
            status: filter.status,
            eventType: filter.eventType,
          );
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref.read(eventRepositoryProvider).getEvents(
            memberId: _filter.memberId,
            startDate: _filter.startDate,
            endDate: _filter.endDate,
            status: _filter.status,
            eventType: _filter.eventType,
          );
    });
  }

  Future<HealthEvent> createEvent(EventCreate data) async {
    final event = await ref.read(eventRepositoryProvider).createEvent(data);
    await refresh();
    return event;
  }

  Future<HealthEvent> updateEvent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final event =
        await ref.read(eventRepositoryProvider).updateEvent(id, updates);
    await refresh();
    return event;
  }

  Future<void> completeEvent(String id) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        _filter.status == 'pending'
            ? current.where((event) => event.id != id).toList()
            : current
                .map(
                  (event) => event.id == id
                      ? event.copyWith(
                          status: 'completed',
                          completedAt: DateTime.now(),
                        )
                      : event,
                )
                .toList(),
      );
    }

    try {
      await ref.read(eventRepositoryProvider).completeEvent(id);
    } catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> deleteEvent(String id) async {
    await ref.read(eventRepositoryProvider).deleteEvent(id);
    await refresh();
  }
}

@riverpod
Future<HealthEvent> eventDetail(EventDetailRef ref, String id) {
  return ref.read(eventRepositoryProvider).getEvent(id);
}
