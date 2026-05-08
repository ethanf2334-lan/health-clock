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
  EventListFilter? _filter;
  int _requestSerial = 0;

  @override
  Future<List<HealthEvent>> build() async {
    final filter = _filter;
    if (filter == null) return const <HealthEvent>[];
    return _fetch(filter);
  }

  Future<void> setFilter(EventListFilter filter) async {
    _filter = filter;
    await _reload(filter);
  }

  Future<void> refresh() async {
    final filter = _filter;
    if (filter == null) {
      state = const AsyncValue.data(<HealthEvent>[]);
      return;
    }
    await _reload(filter);
  }

  Future<List<HealthEvent>> _fetch(EventListFilter filter) {
    return ref.read(eventRepositoryProvider).getEvents(
          memberId: filter.memberId,
          startDate: filter.startDate,
          endDate: filter.endDate,
          status: filter.status,
          eventType: filter.eventType,
        );
  }

  Future<void> _reload(EventListFilter filter) async {
    final requestId = ++_requestSerial;
    state = const AsyncLoading<List<HealthEvent>>().copyWithPrevious(state);

    try {
      final events = await _fetch(filter);
      if (requestId != _requestSerial) return;
      state = AsyncValue.data(events);
    } catch (error, stackTrace) {
      if (requestId != _requestSerial) return;
      state = AsyncValue<List<HealthEvent>>.error(
        error,
        stackTrace,
      ).copyWithPrevious(state);
    }
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
        _filter?.status == 'pending'
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
