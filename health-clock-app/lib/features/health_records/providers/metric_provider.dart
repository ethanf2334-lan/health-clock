import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/metric_record.dart';
import '../data/metric_repository.dart';

part 'metric_provider.g.dart';

class MetricFilter {
  final String? memberId;
  final String? metricType;
  const MetricFilter({this.memberId, this.metricType});
}

@riverpod
class MetricList extends _$MetricList {
  MetricFilter _filter = const MetricFilter();

  @override
  Future<List<MetricRecord>> build() {
    return ref.read(metricRepositoryProvider).listMetrics(
          memberId: _filter.memberId,
          metricType: _filter.metricType,
        );
  }

  Future<void> setFilter(MetricFilter filter) async {
    _filter = filter;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(metricRepositoryProvider).listMetrics(
            memberId: filter.memberId,
            metricType: filter.metricType,
          ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(metricRepositoryProvider).listMetrics(
            memberId: _filter.memberId,
            metricType: _filter.metricType,
          ),
    );
  }

  Future<MetricRecord> add(MetricRecordCreate data) async {
    final rec = await ref.read(metricRepositoryProvider).createMetric(data);
    await refresh();
    return rec;
  }

  Future<void> delete(String id) async {
    await ref.read(metricRepositoryProvider).deleteMetric(id);
    await refresh();
  }
}
