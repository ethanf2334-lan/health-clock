import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/health_event.dart';
import '../../ai_input/presentation/ai_quick_create_panel.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/event_provider.dart';

enum EventRange { today, week, month, all }

enum EventView { list, week, month }

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  EventRange _range = EventRange.week;
  EventView _view = EventView.list;
  bool _showCompleted = false;
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilter());
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? start;
    DateTime? end;

    switch (_view) {
      case EventView.list:
        start = today;
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
        break;
      case EventView.week:
        start = _startOfWeek(_focusedDate);
        end = start.add(const Duration(days: 7));
        break;
      case EventView.month:
        start = DateTime(_focusedDate.year, _focusedDate.month);
        end = DateTime(_focusedDate.year, _focusedDate.month + 1);
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
        _buildViewBar(),
        if (_view == EventView.list) _buildRangeBar(),
        Expanded(
          child: eventsAsync.when(
            data: (events) => _view == EventView.list
                ? _buildList(events)
                : _buildCalendar(events),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败：$e')),
          ),
        ),
        AIQuickCreatePanel(
          compact: true,
          onCreated: (_) => _applyFilter(),
        ),
      ],
    );
  }

  Widget _buildViewBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<EventView>(
              segments: const [
                ButtonSegment(
                  value: EventView.list,
                  icon: Icon(Icons.view_agenda_outlined),
                  label: Text('列表'),
                ),
                ButtonSegment(
                  value: EventView.week,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('周'),
                ),
                ButtonSegment(
                  value: EventView.month,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('月'),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) {
                setState(() {
                  _view = s.first;
                  _focusedDate = _selectedDate;
                });
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
        ],
      ),
    );
  }

  Widget _buildCalendar(List<HealthEvent> events) {
    final selectedEvents = events
        .where((e) => _isSameDay(e.scheduledAt.toLocal(), _selectedDate))
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _buildCalendarHeader(),
          if (_view == EventView.week)
            _buildWeekGrid(events)
          else
            _buildMonthGrid(events),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              DateFormat('M月d日 EEEE', 'zh_CN').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (selectedEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: Text(
                  '当天暂无提醒',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...selectedEvents.map(_buildTile),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final title = _view == EventView.week
        ? '${DateFormat('M月d日', 'zh_CN').format(_startOfWeek(_focusedDate))} - ${DateFormat('M月d日', 'zh_CN').format(_startOfWeek(_focusedDate).add(const Duration(days: 6)))}'
        : DateFormat('yyyy年M月', 'zh_CN').format(_focusedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: '上一页',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _moveCalendar(-1),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              setState(() {
                _focusedDate = today;
                _selectedDate = today;
              });
              _applyFilter();
            },
            child: const Text('今天'),
          ),
          IconButton(
            tooltip: '下一页',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _moveCalendar(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(List<HealthEvent> events) {
    final start = _startOfWeek(_focusedDate);
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildDayCell(day, events, inCurrentMonth: true),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonthGrid(List<HealthEvent> events) {
    final first = DateTime(_focusedDate.year, _focusedDate.month);
    final start = _startOfWeek(first);
    final days = List.generate(42, (i) => start.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: const ['一', '二', '三', '四', '五', '六', '日']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, index) {
              final day = days[index];
              return _buildDayCell(
                day,
                events,
                inCurrentMonth: day.month == _focusedDate.month,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    List<HealthEvent> events, {
    required bool inCurrentMonth,
  }) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final count = events
        .where((e) => _isSameDay(e.scheduledAt.toLocal(), normalizedDay))
        .length;
    final selected = _isSameDay(normalizedDay, _selectedDate);
    final now = DateTime.now();
    final today =
        _isSameDay(normalizedDay, DateTime(now.year, now.month, now.day));
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final shouldRefetch = _view == EventView.month &&
            normalizedDay.month != _focusedDate.month;
        setState(() {
          _selectedDate = normalizedDay;
          if (shouldRefetch) {
            _focusedDate = normalizedDay;
          }
        });
        if (shouldRefetch) {
          _applyFilter();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : today
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _view == EventView.week
                  ? DateFormat('E', 'zh_CN').format(normalizedDay)
                  : '${normalizedDay.day}',
              style: TextStyle(
                fontSize: _view == EventView.week ? 12 : 13,
                color: inCurrentMonth ? null : Colors.grey,
                fontWeight:
                    selected || today ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (_view == EventView.week) ...[
              const SizedBox(height: 2),
              Text(
                '${normalizedDay.day}',
                style: TextStyle(
                  fontSize: 18,
                  color: inCurrentMonth ? null : Colors.grey,
                  fontWeight:
                      selected || today ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            SizedBox(
              height: 18,
              child: count == 0
                  ? const SizedBox.shrink()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<HealthEvent> events) {
    if (events.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight < 160) {
            return Center(
              child: Text('暂无提醒', style: TextStyle(color: Colors.grey[600])),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 56, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text('暂无提醒', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/events/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('手动创建提醒'),
                ),
              ],
            ),
          );
        },
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
    final repeat = _repeatLabel(e.repeatRule);
    final meta = [
      e.isAllDay ? '全天' : time,
      _typeLabel(e.eventType),
      if (repeat != null) repeat,
    ].join('  ·  ');
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
        subtitle: Text(meta),
        trailing: isDone
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                tooltip: '标记完成',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  try {
                    await ref
                        .read(eventListProvider.notifier)
                        .completeEvent(e.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 900),
                            content: Text('已标记完成'),
                          ),
                        );
                    }
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text('操作失败：$error')),
                        );
                    }
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
      backgroundColor: done
          ? Colors.grey[300]
          : Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        icon,
        color: done
            ? Colors.grey[600]
            : Theme.of(context).colorScheme.onPrimaryContainer,
      ),
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

  String? _repeatLabel(Map<String, dynamic>? repeatRule) {
    final frequency = repeatRule?['frequency'] as String?;
    final interval = (repeatRule?['interval'] as num?)?.toInt() ?? 1;
    if (frequency == null || interval != 1) return null;
    const labels = {
      'daily': '每天',
      'weekly': '每周',
      'monthly': '每月',
    };
    return labels[frequency];
  }

  void _moveCalendar(int direction) {
    setState(() {
      if (_view == EventView.week) {
        _focusedDate = _focusedDate.add(Duration(days: 7 * direction));
      } else {
        _focusedDate =
            DateTime(_focusedDate.year, _focusedDate.month + direction);
      }
      _selectedDate = _view == EventView.week
          ? _startOfWeek(_focusedDate)
          : DateTime(_focusedDate.year, _focusedDate.month, 1);
    });
    _applyFilter();
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
