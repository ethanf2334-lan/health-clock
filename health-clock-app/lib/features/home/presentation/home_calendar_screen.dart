import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../shared/models/health_event.dart';
import '../../ai_input/presentation/ai_quick_create_panel.dart';
import '../../calendar/providers/event_provider.dart';
import '../../members/providers/current_member_provider.dart';
import 'widgets/ai_input_bar.dart';
import 'widgets/date_strip.dart';
import 'widgets/home_header.dart';
import 'widgets/home_section_header.dart';
import 'widgets/manual_reminder_sheet.dart';
import 'widgets/metric_record_sheet.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/reminder_card.dart';
import 'widgets/today_status_card.dart';
import 'widgets/view_switch_bar.dart';

/// 健康日历主页 - 1:1 还原设计稿
class HomeCalendarScreen extends ConsumerStatefulWidget {
  const HomeCalendarScreen({super.key});

  @override
  ConsumerState<HomeCalendarScreen> createState() => _HomeCalendarScreenState();
}

class _HomeCalendarScreenState extends ConsumerState<HomeCalendarScreen> {
  String _range = 'today';
  String _view = 'list';
  DateTime _selectedDate = _today();
  DateTime _periodAnchor = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilter());
  }

  void _applyFilter() {
    final memberId = ref.read(currentMemberIdProvider);
    final today = _today();
    DateTime? start;
    DateTime? end;

    if (_view == 'cal_week') {
      start = _startOfWeek(_periodAnchor);
      end = start.add(const Duration(days: 7));
    } else if (_view == 'cal_month') {
      start = DateTime(_periodAnchor.year, _periodAnchor.month);
      end = DateTime(_periodAnchor.year, _periodAnchor.month + 1);
    } else {
      start = today;
      switch (_range) {
        case 'today':
          end = today.add(const Duration(days: 1));
          break;
        case 'week':
          end = today.add(const Duration(days: 7));
          break;
        case 'month':
          end = today.add(const Duration(days: 30));
          break;
        case 'all':
          start = null;
          end = null;
          break;
      }
    }

    ref.read(eventListProvider.notifier).setFilter(
          EventListFilter(
            memberId: memberId,
            startDate: start,
            endDate: end,
            status: 'pending',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentMemberIdProvider, (_, __) => _applyFilter());
    final eventsAsync = ref.watch(eventListProvider);

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppStyles.spacingS),
                children: [
                  HomeHeader(
                    title: '健康日历',
                    subtitle: _buildSubtitle(eventsAsync),
                  ),
                  _buildStatusCard(eventsAsync),
                  ViewSwitchBar(
                    selectedView: _view,
                    onViewChanged: (v) {
                      setState(() {
                        final wasList = _view == 'list';
                        _view = v;
                        if (v != 'list' && wasList) {
                          _periodAnchor = _selectedDate;
                        }
                      });
                      _applyFilter();
                    },
                  ),
                  _buildModeControls(),
                  if (_view == 'cal_week') _buildDateStrip(eventsAsync),
                  if (_view == 'cal_month') _buildMonthGrid(eventsAsync),
                  QuickActionsRow(
                    actions: [
                      QuickAction(
                        title: '手动创建',
                        subtitle: '添加提醒事项',
                        icon: Icons.add_rounded,
                        iconColor: Colors.white,
                        iconBg: AppColors.mintDeep,
                        onTap: _openManualReminderPanel,
                      ),
                      QuickAction(
                        title: '记录指标',
                        subtitle: '血压、血糖等',
                        icon: Icons.monitor_heart_rounded,
                        iconColor: AppColors.careBlue,
                        iconBg: AppColors.careBlueSoft,
                        onTap: _openMetricRecordPanel,
                      ),
                    ],
                  ),
                  HomeSectionHeader(
                    title: _sectionTitle,
                    actionLabel: '全部提醒',
                    onActionTap: () => context.push('/events'),
                  ),
                  ..._buildReminders(eventsAsync),
                  const SizedBox(height: AppStyles.spacingM),
                ],
              ),
            ),
            AIInputBar(
              placeholder: '试试: 甲状腺三个月后复查',
              onTap: _openAIPanel,
              onMicTap: _openAIPanel,
              onSend: _openAIPanel,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(AsyncValue<List<HealthEvent>> async) {
    return async.maybeWhen(
      data: (events) {
        final today = _today();
        final todayPending = events
            .where(
              (e) =>
                  e.status == 'pending' &&
                  _isSameDay(e.scheduledAt.toLocal(), today),
            )
            .length;
        if (todayPending == 0) return '今天没有待办，可以放轻松一下';
        return '今天需要关注 $todayPending 件健康事项';
      },
      orElse: () => '正在为您整理今天的事项',
    );
  }

  Widget _buildStatusCard(AsyncValue<List<HealthEvent>> async) {
    return async.maybeWhen(
      data: (events) {
        final today = _today();
        final todayEvents = events
            .where(
              (e) => _isSameDay(e.scheduledAt.toLocal(), today),
            )
            .toList();
        final now = DateTime.now();
        final overdueCount = events
            .where(
              (e) =>
                  e.status == 'pending' &&
                  e.scheduledAt.toLocal().isBefore(now),
            )
            .length;
        final followUpCount = todayEvents
            .where(
              (e) => e.eventType == 'follow_up' || e.eventType == 'revisit',
            )
            .length;
        final medicationCount =
            todayEvents.where((e) => e.eventType == 'medication').length;
        final checkupCount =
            todayEvents.where((e) => e.eventType == 'checkup').length;

        final title = _statusTitle(
          todayEvents.length,
          overdueCount,
        );
        final summary = _statusSummary(
          followUpCount,
          medicationCount,
          checkupCount,
          overdueCount,
        );

        return TodayStatusCard(
          title: title,
          summary: summary,
          followUpCount: followUpCount,
          medicationCount: medicationCount,
          checkupCount: checkupCount,
          overdueCount: overdueCount,
        );
      },
      orElse: () => const TodayStatusCard(
        title: '正在加载...',
        summary: '稍等片刻',
        followUpCount: 0,
        medicationCount: 0,
        checkupCount: 0,
      ),
    );
  }

  String _statusTitle(int todayCount, int overdueCount) {
    if (overdueCount > 0) return '有事情在等你';
    if (todayCount >= 3) return '今天需要多留意';
    if (todayCount > 0) return '今天节奏可控';
    return '今天很轻松';
  }

  String _statusSummary(
    int followUp,
    int medication,
    int checkup,
    int overdue,
  ) {
    final parts = <String>[];
    if (followUp > 0) parts.add('$followUp 个复查提醒');
    if (medication > 0) parts.add('$medication 个用药提醒');
    if (checkup > 0) parts.add('$checkup 个体检提醒');
    if (overdue > 0) parts.add('$overdue 个逾期事项');
    if (parts.isEmpty) return '今天没有特别需要关注的健康事项';
    return parts.join(' · ');
  }

  Widget _buildDateStrip(AsyncValue<List<HealthEvent>> async) {
    final start = _view == 'cal_week' ? _startOfWeek(_periodAnchor) : _today();
    final items = <DateStripItem>[];

    final allEvents = async.maybeWhen(
      data: (e) => e,
      orElse: () => <HealthEvent>[],
    );

    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final dayEvents = allEvents
          .where((e) => _isSameDay(e.scheduledAt.toLocal(), date))
          .toList();

      final label = _dateLabel(date);

      final dotColors =
          dayEvents.take(3).map((e) => _eventTypeColor(e.eventType)).toList();

      items.add(
        DateStripItem(
          date: date,
          label: label,
          dotColors: dotColors,
        ),
      );
    }

    return DateStrip(
      items: items,
      selected: _selectedDate,
      onSelected: (d) => setState(() => _selectedDate = d),
    );
  }

  Widget _buildMonthGrid(AsyncValue<List<HealthEvent>> async) {
    final allEvents = async.maybeWhen(
      data: (e) => e,
      orElse: () => <HealthEvent>[],
    );
    final firstDay = DateTime(_periodAnchor.year, _periodAnchor.month);
    final daysInMonth =
        DateTime(_periodAnchor.year, _periodAnchor.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1;
    final cells = <MonthDateCell>[];

    for (var i = 0; i < leadingEmpty; i++) {
      cells.add(const MonthDateCell.empty());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_periodAnchor.year, _periodAnchor.month, day);
      final dayEvents = allEvents
          .where((e) => _isSameDay(e.scheduledAt.toLocal(), date))
          .toList();
      cells.add(
        MonthDateCell(
          date: date,
          dotColors: dayEvents
              .take(3)
              .map((e) => _eventTypeColor(e.eventType))
              .toList(),
        ),
      );
    }

    return MonthDateGrid(
      cells: cells,
      selected: _selectedDate,
      onSelected: (d) => setState(() => _selectedDate = d),
    );
  }

  Widget _buildModeControls() {
    if (_view == 'list') {
      return ListRangeBar(
        selectedRange: _range,
        onRangeChanged: (v) {
          setState(() => _range = v);
          _applyFilter();
        },
      );
    }

    return CalendarPeriodBar(
      title: _periodTitle,
      onPrevious: () {
        setState(() {
          _periodAnchor = _shiftPeriod(-1);
          _selectedDate = _periodAnchor;
        });
        _applyFilter();
      },
      onNext: () {
        setState(() {
          _periodAnchor = _shiftPeriod(1);
          _selectedDate = _periodAnchor;
        });
        _applyFilter();
      },
    );
  }

  List<Widget> _buildReminders(AsyncValue<List<HealthEvent>> async) {
    return async.when(
      data: (events) {
        if (events.isEmpty) {
          return [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppStyles.screenMargin,
                0,
                AppStyles.screenMargin,
                AppStyles.spacingM,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.spacingXl,
                  horizontal: AppStyles.cardPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                  border: Border.all(color: AppColors.lightOutline),
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_note_outlined,
                        size: AppStyles.spacingXxl,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppStyles.spacingS),
                      Text(
                        '暂无提醒',
                        style: AppStyles.footnote.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppStyles.spacingXs),
                      Text(
                        '可手动创建，或用 AI 输入一句话生成提醒',
                        style: AppStyles.caption1.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        }

        final sorted = [...events]
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        final visible = sorted.take(8).toList();

        return visible
            .map(
              (e) => Dismissible(
                key: ValueKey('home-reminder-${e.id}'),
                direction: DismissDirection.endToStart,
                background: _buildCompleteDismissBackground(),
                confirmDismiss: (_) async {
                  await _completeReminder(e);
                  return false;
                },
                child: ReminderCard(
                  data: _toCardData(e),
                  onTap: () => context.push('/events/${e.id}'),
                  onComplete: () => _completeReminder(e),
                ),
              ),
            )
            .toList();
      },
      loading: () => const [
        SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (e, _) => [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.screenMargin,
          ),
          child: Text(
            _friendlyErrorMessage(e),
            style: AppStyles.footnote.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteDismissBackground() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingS,
      ),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppStyles.spacingM),
        decoration: BoxDecoration(
          color: AppColors.mintDeep,
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _completeReminder(HealthEvent event) async {
    try {
      await ref.read(eventListProvider.notifier).completeEvent(event.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('已完成：${event.title}'),
            duration: const Duration(milliseconds: 1200),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('标记完成失败，请稍后重试')),
        );
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('500') || message.contains('bad response')) {
      return '提醒加载失败，服务暂时没有返回可用数据。请稍后重试。';
    }
    if (message.contains('receive timeout')) {
      return '提醒加载超时，请检查网络或稍后重试。';
    }
    return '提醒加载失败，请稍后重试。';
  }

  ReminderCardData _toCardData(HealthEvent e) {
    final localTime = e.scheduledAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(localTime.year, localTime.month, localTime.day);
    final daysDiff = eventDay.difference(today).inDays;

    String timeText;
    final timeStr = e.isAllDay ? '' : DateFormat('HH:mm').format(localTime);
    if (daysDiff == 0) {
      timeText = e.isAllDay ? '今天' : '今天 $timeStr';
    } else if (daysDiff == 1) {
      timeText = e.isAllDay ? '明天' : '明天 $timeStr';
    } else if (daysDiff == 2) {
      timeText = e.isAllDay ? '后天' : '后天 $timeStr';
    } else if (daysDiff > 2 && daysDiff < 7) {
      timeText = e.isAllDay
          ? DateFormat('M月d日').format(localTime)
          : DateFormat('M月d日 HH:mm').format(localTime);
    } else {
      timeText = DateFormat('M月d日').format(localTime);
    }

    final isOverdue = e.status == 'pending' && localTime.isBefore(now);
    final timeColor = isOverdue
        ? AppColors.danger
        : (daysDiff <= 0 ? AppColors.coral : AppColors.textSecondary);

    final iconColor = _eventTypeColor(e.eventType);
    final iconBg = _eventTypeBg(e.eventType);
    final tagInfo = _eventTypeTag(e.eventType);
    final source = _sourceLabel(e.sourceType);

    return ReminderCardData(
      title: e.title,
      source: '来源：$source',
      tag: tagInfo.$1,
      timeText: timeText,
      icon: _eventTypeIcon(e.eventType),
      iconColor: iconColor,
      iconBg: iconBg,
      tagColor: tagInfo.$2,
      tagBg: tagInfo.$3,
      timeColor: timeColor,
      isOverdue: isOverdue,
    );
  }

  void _openAIPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.68,
              child: AIQuickCreatePanel(
                onCreated: (_) {
                  Navigator.pop(ctx);
                  _applyFilter();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openManualReminderPanel() {
    showModalBottomSheet<HealthEvent>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.73,
              child: ManualReminderSheet(
                onCreated: (_) => _applyFilter(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMetricRecordPanel() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.73,
              child: const MetricRecordSheet(),
            ),
          ),
        );
      },
    );
  }

  Color _eventTypeColor(String type) {
    switch (type) {
      case 'follow_up':
        return AppColors.coral;
      case 'revisit':
        return AppColors.coral;
      case 'checkup':
        return AppColors.warmAmber;
      case 'medication':
        return AppColors.rose;
      case 'monitoring':
        return AppColors.lavender;
      default:
        return AppColors.mintDeep;
    }
  }

  Color _eventTypeBg(String type) {
    switch (type) {
      case 'follow_up':
      case 'revisit':
        return AppColors.coralSoft;
      case 'checkup':
        return AppColors.amberSoft;
      case 'medication':
        return AppColors.roseSoft;
      case 'monitoring':
        return AppColors.lavenderSoft;
      default:
        return AppColors.mintSoft;
    }
  }

  IconData _eventTypeIcon(String type) {
    switch (type) {
      case 'follow_up':
      case 'revisit':
        return Icons.healing_rounded;
      case 'checkup':
        return Icons.medical_services_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'monitoring':
        return Icons.monitor_heart_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  /// 返回 (label, textColor, bgColor)
  (String, Color, Color) _eventTypeTag(String type) {
    switch (type) {
      case 'follow_up':
      case 'revisit':
        return ('复查', AppColors.coral, AppColors.coralSoft);
      case 'checkup':
        return ('体检', AppColors.warmAmber, AppColors.amberSoft);
      case 'medication':
        return ('用药', AppColors.rose, AppColors.roseSoft);
      case 'monitoring':
        return ('监测', AppColors.lavender, AppColors.lavenderSoft);
      default:
        return ('提醒', AppColors.mintDeep, AppColors.mintSoft);
    }
  }

  String _sourceLabel(String type) {
    switch (type) {
      case 'manual':
        return '手动创建';
      case 'ai_text':
        return 'AI 文本输入';
      case 'ai_voice':
        return 'AI 语音输入';
      case 'document':
        return '体检报告识别';
      default:
        return type;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _shiftPeriod(int direction) {
    if (_view == 'cal_week') {
      return _periodAnchor.add(Duration(days: 7 * direction));
    }
    return DateTime(_periodAnchor.year, _periodAnchor.month + direction);
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  String get _periodTitle {
    if (_view == 'cal_week') {
      final start = _startOfWeek(_periodAnchor);
      final end = start.add(const Duration(days: 6));
      return '${DateFormat('M月d日', 'zh_CN').format(start)} - ${DateFormat('M月d日', 'zh_CN').format(end)}';
    }
    return DateFormat('yyyy年M月', 'zh_CN').format(_periodAnchor);
  }

  String get _sectionTitle {
    switch (_view) {
      case 'cal_week':
        return '本周提醒';
      case 'cal_month':
        return '本月提醒';
      default:
        return '近期提醒';
    }
  }

  String _dateLabel(DateTime date) {
    final today = _today();
    final diff =
        DateTime(date.year, date.month, date.day).difference(today).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == 2) return '后天';
    return '${date.month}/${date.day}';
  }
}
