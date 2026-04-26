import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/app_status_chip.dart';
import '../../../shared/widgets/app_surface_card.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
    final labels = {
      EventRange.today: '今日',
      EventRange.week: '7天',
      EventRange.month: '30天',
      EventRange.all: '全部',
    };

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemBuilder: (context, index) {
          final range = EventRange.values[index];
          final selected = _range == range;
          return ChoiceChip(
            label: Text(labels[range]!),
            selected: selected,
            onSelected: (_) {
              setState(() => _range = range);
              _applyFilter();
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: EventRange.values.length,
      ),
    );
  }

  Widget _buildCareSummary(AsyncValue<List<HealthEvent>> eventsAsync) {
    return eventsAsync.maybeWhen(
      data: (events) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayCount = events
            .where((e) => _isSameDay(e.scheduledAt.toLocal(), today))
            .length;
        final overdueCount = events
            .where(
              (e) =>
                  e.status == 'pending' &&
                  e.scheduledAt.toLocal().isBefore(now),
            )
            .length;
        final nextEvent = [...events]
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        final nextPending = nextEvent
            .where((e) => e.status == 'pending' && !e.scheduledAt.isBefore(now))
            .cast<HealthEvent?>()
            .firstWhere((e) => e != null, orElse: () => null);
        final mood = _careMood(todayCount, overdueCount);
        final moodColor = _moodColor(mood);

        return AppSurfaceCard(
          margin: const EdgeInsets.fromLTRB(16, 2, 16, 12),
          padding: EdgeInsets.zero,
          color: Color.alphaBlend(
            moodColor.withValues(alpha: 0.08),
            Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _CareMoodOrb(
                      mood: mood,
                      color: moodColor,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppStatusChip(
                            label: _moodLabel(mood),
                            icon: _moodIcon(mood),
                            color: moodColor,
                            compact: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _summaryTitle(todayCount, overdueCount),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _summaryMessage(nextPending, mood),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.76),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.radiusLg),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: _buildCareRhythm(events, today),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildCareRhythm(List<HealthEvent> events, DateTime today) {
    final days = List.generate(7, (i) => today.add(Duration(days: i)));
    final weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '未来 7 天健康事项',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '颜色越深事项越多',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: days.map((day) {
            final dayEvents = events
                .where((e) => _isSameDay(e.scheduledAt.toLocal(), day))
                .toList();
            final count = dayEvents.length;
            final dayColor = _dayColor(dayEvents);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          dayColor.withValues(alpha: count == 0 ? 0.10 : 0.82),
                          colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dayColor.withValues(alpha: 0.20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: count == 0
                          ? Icon(
                              Icons.remove,
                              size: 14,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.42),
                            )
                          : Text(
                              '$count',
                              style: TextStyle(
                                color: count >= 3
                                    ? Colors.white
                                    : Color.alphaBlend(
                                        dayColor.withValues(alpha: 0.80),
                                        colorScheme.onSurface,
                                      ),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weekdayLabels[day.weekday - 1],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: _isSameDay(day, today)
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _summaryTitle(int todayCount, int overdueCount) {
    if (overdueCount > 0) return '有事情在等你';
    if (todayCount >= 4) return '今天需要多留意';
    if (todayCount > 0) return '今天节奏可控';
    return '今天很轻松';
  }

  String _summaryMessage(HealthEvent? nextPending, _CareMood mood) {
    if (nextPending == null) {
      return '没有待办提醒。可以把复查、用药或检查安排交给底部 AI 记录。';
    }
    final lead = switch (mood) {
      _CareMood.calm => '保持现在的节奏就好',
      _CareMood.steady => '按计划慢慢处理',
      _CareMood.busy => '先抓最靠近的一件事',
      _CareMood.alert => '建议先处理逾期事项',
    };
    return '$lead：${nextPending.title} · ${_formatNextTime(nextPending)}';
  }

  _CareMood _careMood(int todayCount, int overdueCount) {
    if (overdueCount > 0) return _CareMood.alert;
    if (todayCount >= 4) return _CareMood.busy;
    if (todayCount > 0) return _CareMood.steady;
    return _CareMood.calm;
  }

  Color _moodColor(_CareMood mood) {
    return switch (mood) {
      _CareMood.calm => AppColors.careBlue,
      _CareMood.steady => AppColors.seed,
      _CareMood.busy => AppColors.warmAmber,
      _CareMood.alert => AppColors.danger,
    };
  }

  String _moodLabel(_CareMood mood) {
    return switch (mood) {
      _CareMood.calm => '状态轻松',
      _CareMood.steady => '状态稳定',
      _CareMood.busy => '稍微忙碌',
      _CareMood.alert => '需要关注',
    };
  }

  IconData _moodIcon(_CareMood mood) {
    return switch (mood) {
      _CareMood.calm => Icons.spa_outlined,
      _CareMood.steady => Icons.favorite_outline,
      _CareMood.busy => Icons.notifications_active_outlined,
      _CareMood.alert => Icons.error_outline,
    };
  }

  Color _dayColor(List<HealthEvent> events) {
    if (events.isEmpty) return AppColors.careBlue;
    if (events.length >= 5) return AppColors.danger;
    return _eventTypeColor(events.first.eventType);
  }

  String _formatNextTime(HealthEvent event) {
    final local = event.scheduledAt.toLocal();
    if (event.isAllDay) return DateFormat('M月d日').format(local);
    return DateFormat('M月d日 HH:mm').format(local);
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
                    selected || today ? FontWeight.w600 : FontWeight.w500,
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
                      selected || today ? FontWeight.w600 : FontWeight.w500,
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
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _buildCareSummary(AsyncValue.data(events)),
                const AppEmptyState(
                  icon: Icons.event_note_outlined,
                  title: '暂无提醒',
                  compact: true,
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildCareSummary(AsyncValue.data(events)),
              AppEmptyState(
                icon: Icons.event_note_outlined,
                title: '暂无提醒',
                message: '可以手动创建，或者用底部 AI 输入一句话生成提醒。',
                action: FilledButton.icon(
                  onPressed: () => context.push('/events/new'),
                  icon: const Icon(Icons.add_alert_outlined),
                  label: const Text('手动创建'),
                ),
              ),
            ],
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
        itemCount: keys.length + 1,
        itemBuilder: (_, idx) {
          if (idx == 0) {
            return _buildCareSummary(AsyncValue.data(events));
          }
          final keyIndex = idx - 1;
          final k = keys[keyIndex];
          final list = grouped[k]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: k,
                trailing: Text(
                  '${list.length} 条',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      onTap: () => context.push('/events/${e.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _typeIcon(e.eventType, isDone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? colorScheme.onSurfaceVariant : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isDone
              ? const AppStatusChip(
                  label: '已完成',
                  icon: Icons.check,
                  color: AppColors.success,
                  compact: true,
                )
              : IconButton.filledTonal(
                  tooltip: '标记完成',
                  icon: const Icon(Icons.check),
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
        ],
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
    final color = _eventTypeColor(type);
    return CircleAvatar(
      backgroundColor: done ? Colors.grey[300] : color.withValues(alpha: 0.18),
      child: Icon(
        icon,
        color: done ? Colors.grey[600] : color,
      ),
    );
  }

  Color _eventTypeColor(String type) {
    switch (type) {
      case 'follow_up':
        return AppColors.careBlue;
      case 'revisit':
        return AppColors.coral;
      case 'checkup':
        return AppColors.sun;
      case 'medication':
        return AppColors.rose;
      case 'monitoring':
        return AppColors.lavender;
      default:
        return AppColors.seed;
    }
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

enum _CareMood { calm, steady, busy, alert }

class _CareMoodOrb extends StatelessWidget {
  const _CareMoodOrb({
    required this.mood,
    required this.color,
  });

  final _CareMood mood;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _CareMoodOrbPainter(
          mood: mood,
          color: color,
          surface: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

class _CareMoodOrbPainter extends CustomPainter {
  const _CareMoodOrbPainter({
    required this.mood,
    required this.color,
    required this.surface,
  });

  final _CareMood mood;
  final Color color;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.52);
    final radius = size.shortestSide * 0.34;
    final shadow = Paint()
      ..color = color.withValues(alpha: 0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center.translate(0, 8), radius * 1.08, shadow);

    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 1.1,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.34), color),
          color,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, body);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center.translate(-radius * 0.32, -radius * 0.35),
      radius * 0.20,
      highlight,
    );

    final cheek = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(center.translate(radius * 0.38, radius * 0.05), 5, cheek);

    final feature = Paint()
      ..color = _faceColor()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final leftEye = center.translate(-radius * 0.28, -radius * 0.08);
    final rightEye = center.translate(radius * 0.22, -radius * 0.08);

    if (mood == _CareMood.alert || mood == _CareMood.busy) {
      canvas.drawLine(
        leftEye.translate(-3, -2),
        leftEye.translate(3, 2),
        feature,
      );
      canvas.drawLine(
        rightEye.translate(-3, 2),
        rightEye.translate(3, -2),
        feature,
      );
    } else {
      canvas.drawCircle(leftEye, 2.4, feature);
      canvas.drawCircle(rightEye, 2.4, feature);
    }

    final mouth = Path();
    final mouthY = center.dy + radius * 0.18;
    if (mood == _CareMood.alert) {
      mouth.moveTo(center.dx - 8, mouthY + 3);
      mouth.quadraticBezierTo(center.dx, mouthY - 4, center.dx + 8, mouthY + 3);
    } else if (mood == _CareMood.busy) {
      canvas.drawLine(
        Offset(center.dx - 8, mouthY),
        Offset(center.dx + 8, mouthY),
        feature,
      );
    } else {
      mouth.moveTo(center.dx - 9, mouthY - 2);
      mouth.quadraticBezierTo(center.dx, mouthY + 8, center.dx + 9, mouthY - 2);
    }
    if (mood != _CareMood.busy) {
      canvas.drawPath(mouth, feature..style = PaintingStyle.stroke);
    }

    final handPaint = Paint()
      ..color = _faceColor().withValues(alpha: 0.76)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawLine(
      center.translate(radius * 0.66, -radius * 0.58),
      center.translate(radius * 0.86, -radius * 0.82),
      handPaint,
    );
    canvas.drawLine(
      center.translate(radius * 0.66, -radius * 0.58),
      center.translate(radius * 0.90, -radius * 0.50),
      handPaint,
    );

    final tickPaint = Paint()
      ..color = _faceColor().withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.18),
      -0.4,
      1.15,
      false,
      tickPaint,
    );
  }

  Color _faceColor() {
    return mood == _CareMood.alert
        ? const Color(0xFF532626)
        : const Color(0xFF123C35);
  }

  @override
  bool shouldRepaint(covariant _CareMoodOrbPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.color != color ||
        oldDelegate.surface != surface;
  }
}
