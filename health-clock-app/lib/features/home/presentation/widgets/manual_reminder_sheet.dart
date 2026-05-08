import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/models/health_event.dart';
import '../../../../shared/widgets/app_cupertino_pickers.dart';
import '../../../calendar/providers/event_provider.dart';
import '../../../members/presentation/widgets/member_avatar.dart';
import '../../../members/providers/current_member_provider.dart';
import '../../../members/providers/member_provider.dart';

class ManualReminderSheet extends ConsumerStatefulWidget {
  const ManualReminderSheet({super.key, this.onCreated});

  final ValueChanged<HealthEvent>? onCreated;

  @override
  ConsumerState<ManualReminderSheet> createState() =>
      _ManualReminderSheetState();
}

class _ManualReminderSheetState extends ConsumerState<ManualReminderSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _eventType = 'follow_up';
  String? _memberId;
  DateTime _scheduledAt = _initialDate();
  bool _appNotify = true;
  bool _sameDayNotify = false;
  bool _saving = false;

  static DateTime _initialDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  static const _types = [
    _ReminderType('follow_up', '复查', Icons.search_rounded, AppColors.rose),
    _ReminderType(
      'revisit',
      '复诊',
      Icons.medical_services_outlined,
      AppColors.careBlue,
    ),
    _ReminderType(
      'medication',
      '用药',
      Icons.medication_rounded,
      AppColors.mintDeep,
    ),
    _ReminderType(
      'checkup',
      '体检',
      Icons.medical_information_outlined,
      AppColors.warmAmber,
    ),
    _ReminderType(
      'monitoring',
      '监测',
      Icons.monitor_heart_outlined,
      AppColors.lavender,
    ),
    _ReminderType(
      'custom',
      '自定义',
      Icons.more_horiz_rounded,
      AppColors.textPrimary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    final membersAsync = ref.watch(memberListProvider);
    final memberName = _memberName(membersAsync);
    final memberRelation = _memberRelation(membersAsync);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppStyles.spacingM,
            AppStyles.spacingS,
            AppStyles.spacingM,
            AppStyles.spacingM + MediaQuery.of(context).padding.bottom * 0.18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: AppStyles.spacingXs,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8C0C3),
                    borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildHeader(),
              const SizedBox(height: AppStyles.spacingM),
              const _FieldLabel('提醒类型'),
              const SizedBox(height: AppStyles.spacingS),
              _buildTypeGrid(),
              const SizedBox(height: AppStyles.spacingS),
              _LabeledRow(
                label: '成员',
                child: _InputShell(
                  onTap: _showMemberPicker,
                  child: Row(
                    children: [
                      MemberAvatar(
                        name: memberName,
                        relation: memberRelation,
                        size: 24,
                      ),
                      const SizedBox(width: AppStyles.spacingS),
                      Expanded(
                        child: Text(
                          memberName,
                          style: AppStyles.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _LabeledRow(
                label: '提醒标题',
                child: _TextInputShell(
                  controller: _titleController,
                  hintText: '请输入提醒标题',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildDateTimeRow(),
              const SizedBox(height: AppStyles.spacingS),
              const _LabeledRow(
                label: '重复',
                child: _InputShell(
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        size: 22,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: AppStyles.spacingS),
                      Expanded(
                        child: Text(
                          '不重复',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildNotifyRow(),
              const SizedBox(height: AppStyles.spacingS),
              _LabeledRow(
                label: '备注',
                child: _TextInputShell(
                  controller: _noteController,
                  hintText: '可填写准备事项',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildSourceRow(),
              const SizedBox(height: AppStyles.spacingM),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mintBg,
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          child: const Icon(
            Icons.add_box_outlined,
            color: AppColors.mintDeep,
            size: 20,
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '手动添加提醒',
                style: AppStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '为家人创建清晰可靠的健康提醒',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, AppStyles.spacingXs),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeGrid() {
    return Row(
      children: [
        for (final type in _types) ...[
          Expanded(
            child: _TypeTile(
              type: type,
              selected: _eventType == type.value,
              onTap: () => setState(() => _eventType = type.value),
            ),
          ),
          if (type != _types.last) const SizedBox(width: AppStyles.spacingS),
        ],
      ],
    );
  }

  Widget _buildDateTimeRow() {
    return _LabeledRow(
      label: '日期',
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _InputShell(
              onTap: _pickDate,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppStyles.spacingXs),
                  Expanded(
                    child: Text(
                      DateFormat('M/d').format(_scheduledAt),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: AppStyles.subhead.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Text(
            '时间',
            style: AppStyles.subhead.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppStyles.spacingXs),
          Expanded(
            flex: 4,
            child: _InputShell(
              onTap: _pickTime,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppStyles.spacingXs),
                  Expanded(
                    child: Text(
                      DateFormat('HH:mm').format(_scheduledAt),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: AppStyles.subhead.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyRow() {
    return _LabeledRow(
      label: '提醒方式',
      child: Wrap(
        spacing: AppStyles.spacingS,
        runSpacing: AppStyles.spacingS,
        children: [
          _NotifyChip(
            icon: Icons.notifications_none_rounded,
            label: 'App通知',
            selected: _appNotify,
            onTap: () => setState(() => _appNotify = !_appNotify),
          ),
          _NotifyChip(
            icon: Icons.wb_sunny_outlined,
            label: '当天提醒',
            selected: _sameDayNotify,
            onTap: () => setState(() => _sameDayNotify = !_sameDayNotify),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceRow() {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            '来源',
            style: AppStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacingM,
            vertical: AppStyles.spacingS,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3F1),
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
          child: Text(
            '手动创建',
            style: AppStyles.footnote.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: _saving ? null : _save,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34C58A),
                    Color(0xFF16995C),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintDeep.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, AppStyles.spacingS),
                  ),
                ],
              ),
              child: Text(
                _saving ? '创建中...' : '确认创建',
                style: AppStyles.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppStyles.spacingM),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _saving ? null : _reset,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                border: Border.all(color: AppColors.mintDeep),
              ),
              child: Text(
                '重置',
                style: AppStyles.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.mintDeep,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await AppCupertinoPickers.date(
      context: context,
      initialDate: _scheduledAt,
      minimumDate: DateTime.now().subtract(const Duration(days: 1)),
      maximumDate: DateTime(2100),
      title: '选择提醒日期',
    );
    if (date == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        _scheduledAt.hour,
        _scheduledAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final time = await AppCupertinoPickers.time(
      context: context,
      initialDateTime: _scheduledAt,
      title: '选择提醒时间',
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        _scheduledAt.year,
        _scheduledAt.month,
        _scheduledAt.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _showMemberPicker() {
    final membersAsync = ref.read(memberListProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              AppStyles.spacingS,
              0,
              AppStyles.spacingM,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.spacingM,
                  AppStyles.spacingS,
                  AppStyles.spacingM,
                  AppStyles.spacingM,
                ),
                child: Text(
                  '选择成员',
                  style: AppStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...members.map(
                (member) => ListTile(
                  leading: MemberAvatar(
                    name: member.name,
                    relation: member.relation,
                  ),
                  title: Text(
                    member.name,
                    style: AppStyles.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: _memberId == member.id
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mintDeep,
                        )
                      : null,
                  onTap: () {
                    setState(() => _memberId = member.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppStyles.spacingXxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Text('加载失败：$e'),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final memberId = _memberId ?? ref.read(currentMemberIdProvider);
    final title = _titleController.text.trim();
    if (memberId == null || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择成员')),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提醒标题')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final event = await ref.read(eventListProvider.notifier).createEvent(
            EventCreate(
              memberId: memberId,
              title: title,
              description: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
              eventType: _eventType,
              scheduledAt: _scheduledAt,
              notifyOffsets: _notifyOffsets(),
              sourceType: 'manual',
            ),
          );

      try {
        await NotificationService().scheduleEventNotification(
          id: event.id.hashCode & 0x7FFFFFFF,
          title: event.title,
          scheduledDate: event.scheduledAt.toLocal(),
          repeatRule: event.repeatRule,
          payload: 'event:${event.id}',
        );
      } catch (_) {}

      if (!mounted) return;
      widget.onCreated?.call(event);
      Navigator.of(context).pop(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提醒已创建')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<int>? _notifyOffsets() {
    final offsets = <int>[];
    if (_appNotify) offsets.add(0);
    if (_sameDayNotify) offsets.add(60 * 9);
    return offsets.isEmpty ? null : offsets;
  }

  void _reset() {
    setState(() {
      _eventType = 'follow_up';
      _scheduledAt = _initialDate();
      _titleController.clear();
      _noteController.clear();
      _appNotify = true;
      _sameDayNotify = false;
      _memberId = ref.read(currentMemberIdProvider);
    });
  }

  String _memberName(AsyncValue membersAsync) {
    return membersAsync.maybeWhen(
      data: (members) {
        for (final member in members) {
          if (member.id == _memberId) return member.name as String;
        }
        return members.isEmpty ? '妈妈' : members.first.name as String;
      },
      orElse: () => '妈妈',
    );
  }

  String? _memberRelation(AsyncValue membersAsync) {
    return membersAsync.maybeWhen(
      data: (members) {
        for (final member in members) {
          if (member.id == _memberId) return member.relation as String?;
        }
        return members.isEmpty ? null : members.first.relation as String?;
      },
      orElse: () => null,
    );
  }
}

class _ReminderType {
  const _ReminderType(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppStyles.subhead.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 64, child: _FieldLabel(label)),
        Expanded(child: child),
      ],
    );
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Container(
          height: AppStyles.minTouchTarget,
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TextInputShell extends StatelessWidget {
  const _TextInputShell({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppStyles.minTouchTarget,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppStyles.subhead.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(
            AppStyles.spacingM,
            10,
            AppStyles.spacingM,
            10,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : InkWell(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final _ReminderType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final selectedBg = Color.alphaBlend(
      type.color.withValues(alpha: 0.12),
      Colors.white,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(
            color: selected
                ? type.color.withValues(alpha: 0.45)
                : AppColors.lightOutline,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: color, size: 20),
            const SizedBox(height: AppStyles.spacingXs),
            Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppStyles.caption1.fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyChip extends StatelessWidget {
  const _NotifyChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: AppStyles.minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.mintDeep.withValues(alpha: 0.35)
                : AppColors.lightOutline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.mintDeep : AppColors.textSecondary,
            ),
            const SizedBox(width: AppStyles.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: AppStyles.footnote.fontSize,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.mintDeep : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
