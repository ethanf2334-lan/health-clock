import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/metric_record.dart';
import '../../members/presentation/member_switcher.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/metric_provider.dart';

const _types = [
  {'value': null, 'label': '全部'},
  {'value': 'blood_pressure', 'label': '血压'},
  {'value': 'blood_sugar', 'label': '血糖'},
  {'value': 'weight', 'label': '体重'},
  {'value': 'heart_rate', 'label': '心率'},
  {'value': 'temperature', 'label': '体温'},
  {'value': 'blood_oxygen', 'label': '血氧'},
];

class MetricHistoryScreen extends ConsumerStatefulWidget {
  const MetricHistoryScreen({super.key});

  @override
  ConsumerState<MetricHistoryScreen> createState() =>
      _MetricHistoryScreenState();
}

class _MetricHistoryScreenState extends ConsumerState<MetricHistoryScreen> {
  String? _type;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  void _apply() {
    ref.read(metricListProvider.notifier).setFilter(
          MetricFilter(
            memberId: ref.read(currentMemberIdProvider),
            metricType: _type,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentMemberIdProvider, (_, __) => _apply());
    final async = ref.watch(metricListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('健康指标')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/metrics/new'),
        icon: const Icon(Icons.add),
        label: const Text('记录'),
      ),
      body: Column(
        children: [
          const MemberSwitcherBar(),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _types
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(t['label'] as String),
                          selected: _type == t['value'],
                          onSelected: (_) {
                            setState(() => _type = t['value']);
                            _apply();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: async.when(
              data: (list) => _buildBody(list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<MetricRecord> list) {
    if (list.isEmpty) {
      return Center(
        child: Text('暂无记录', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(metricListProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          if (_type != null && _type != 'blood_pressure' && list.length >= 2)
            _buildChart(list),
          ...list.map(_buildTile),
        ],
      ),
    );
  }

  Widget _buildChart(List<MetricRecord> list) {
    final sorted = [...list]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].value));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(MetricRecord r) {
    String valueText = '${r.value}${r.unit}';
    if (r.metricType == 'blood_pressure' && r.valueExtra != null) {
      final d = r.valueExtra!['diastolic'];
      valueText = '${r.value}/${d}${r.unit}';
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _typeIcon(r.metricType),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text('${_typeLabel(r.metricType)}  $valueText'),
        subtitle: Text(
          [
            DateFormat('yyyy-MM-dd HH:mm').format(r.recordedAt.toLocal()),
            if (r.note != null && r.note!.isNotEmpty) r.note!,
          ].join('  ·  '),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('删除记录'),
                content: const Text('确定删除这条指标记录？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('删除'),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await ref.read(metricListProvider.notifier).delete(r.id);
            }
          },
        ),
      ),
    );
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'blood_pressure':
        return Icons.favorite;
      case 'blood_sugar':
        return Icons.bloodtype;
      case 'weight':
        return Icons.monitor_weight;
      case 'height':
        return Icons.height;
      case 'heart_rate':
        return Icons.monitor_heart;
      case 'temperature':
        return Icons.thermostat;
      case 'blood_oxygen':
        return Icons.air;
      default:
        return Icons.show_chart;
    }
  }

  String _typeLabel(String t) {
    const m = {
      'blood_pressure': '血压',
      'blood_sugar': '血糖',
      'weight': '体重',
      'height': '身高',
      'heart_rate': '心率',
      'temperature': '体温',
      'blood_oxygen': '血氧',
    };
    return m[t] ?? t;
  }
}
