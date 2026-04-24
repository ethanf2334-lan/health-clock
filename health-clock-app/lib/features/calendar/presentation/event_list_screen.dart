import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/health_event.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/event_provider.dart';

enum EventRange { today, week, month, all }

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  EventRange _range = EventRange.week;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilter());
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? start = today;
    DateTime? end;

    switch (_range) {
      case EventRange.today:
        end = today.add(const Duration(days: 1));
        break;
      case EventRange.week:
        end = today.add(const Duration(days: 7));
        break;
      case EventRange.month:
        end = today.add(const Duration(days: 30));
        break;
      case EventRange.all:
        start = null;
        end = null;
        break;
    }

    final memberId = ref.read(currentMemberIdProvider);
    ref.read(eventListProvider.notifier).setFilter(
          EventListFilter(
            memberId: memberId,
            startDate: start,
            endDate: end,
            status: _showCompleted ? null : 'pending',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentMemberIdProvider, (_, __) => _applyFilter());
    final eventsAsync = ref.watch(eventListProvider);

    return Column(
      children: [
        _buildRangeBar(),
        Expanded(
          child: eventsAsync.when(
            data: (events) => _buildList(events),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败：$e')),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<EventRange>(
              segments: const [
                ButtonSegment(value: EventRange.today, label: Text('今日')),
                ButtonSegment(value: EventRange.week, label: Text('7天')),
                ButtonSegment(value: EventRange.month, label: Text('30天')),
                ButtonSegment(value: EventRange.all, label: Text('全部')),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                setState(() => _range = s.first);
                _applyFilter();
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: _showCompleted ? '隐藏已完成' : '显示已完成',
            icon: Icon(
              _showCompleted ? Icons.check_circle : Icons.check_circle_outline,
            ),
            onPressed: () {
              setState(() => _showCompleted = !_showCompleted);
              _applyFilter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<HealthEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('暂无提醒', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/events/new'),
              icon: const Icon(Icons.add),
              label: const Text('手动创建提醒'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/ai-input'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI 创建提醒'),
            ),
          ],
        ),
      );
    }

    final grouped = <String, List<HealthEvent>>{};
    final dateFmt = DateFormat('yyyy-MM-dd EEE', 'zh_CN');
    for (final e in events) {
      final key = dateFmt.format(e.scheduledAt.toLocal());
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final keys = grouped.keys.toList();
    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: keys.length,
        itemBuilder: (_, idx) {
          final k = keys[idx];
          final list = grouped[k]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  k,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...list.map(_buildTile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile(HealthEvent e) {
    final time = DateFormat('HH:mm').format(e.scheduledAt.toLocal());
    final isDone = e.status == 'completed';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: _typeIcon(e.eventType, isDone),
        title: Text(
          e.title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          e.isAllDay ? '全天  ·  ${_typeLabel(e.eventType)}' : '$time  ·  ${_typeLabel(e.eventType)}',
        ),
        trailing: isDone
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                tooltip: '标记完成',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  await ref
                      .read(eventListProvider.notifier)
                      .completeEvent(e.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已标记完成')),
                    );
                  }
                },
              ),
        onTap: () => context.push('/events/${e.id}'),
      ),
    );
  }

  Widget _typeIcon(String type, bool done) {
    IconData icon;
    switch (type) {
      case 'follow_up':
        icon = Icons.refresh;
        break;
      case 'revisit':
        icon = Icons.local_hospital;
        break;
      case 'checkup':
        icon = Icons.fact_check;
        break;
      case 'medication':
        icon = Icons.medication;
        break;
      case 'monitoring':
        icon = Icons.monitor_heart;
        break;
      default:
        icon = Icons.event;
    }
    return CircleAvatar(
      backgroundColor:
          done ? Colors.grey[300] : Theme.of(context).colorScheme.primaryContainer,
      child: Icon(icon,
          color: done
              ? Colors.grey[600]
              : Theme.of(context).colorScheme.onPrimaryContainer),
    );
  }

  String _typeLabel(String type) {
    const m = {
      'follow_up': '复查',
      'revisit': '复诊',
      'checkup': '体检',
      'medication': '用药',
      'monitoring': '监测',
      'custom': '自定义',
    };
    return m[type] ?? type;
  }
}
