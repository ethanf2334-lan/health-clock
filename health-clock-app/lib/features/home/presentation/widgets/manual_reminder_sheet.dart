import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/models/health_event.dart';
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
  final _titleController = TextEditingController(text: '肺结节 CT 复查');
  final _noteController = TextEditingController(text: '带上既往检查报告');

  String _eventType = 'follow_up';
  String? _memberId;
  DateTime _scheduledAt = _initialDate();
  bool _appNotify = true;
  bool _sameDayNotify = false;
  bool _saving = false;

  static DateTime _initialDate() {
    final now = DateTime.now();
    final base = now.add(const Duration(days: 14));
    return DateTime(base.year, base.month, base.day, 9, 30);
  }

  static const _types = [
    _ReminderType('follow_up', '复查', Icons.search_rounded, AppColors.rose),
    _ReminderType(
      'revisit',
      '复诊',
      Icons.medical_services_outlined,
      AppColors.textSecondary,
    ),
    _ReminderType(
      'medication',
      '用药',
      Icons.medication_rounded,
      AppColors.textSecondary,
    ),
    _ReminderType(
      'checkup',
      '体检',
      Icons.medical_information_outlined,
      AppColors.textSecondary,
    ),
    _ReminderType(
      'monitoring',
      '监测',
      Icons.monitor_heart_outlined,
      AppColors.textSecondary,
    ),
    _ReminderType(
      'custom',
      '自定义',
      Icons.more_horiz_rounded,
      AppColors.textSecondary,
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
    final selectedType = _types.firstWhere(
      (type) => type.value == _eventType,
      orElse: () => _types.first,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            18 + MediaQuery.of(context).padding.bottom * 0.18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8C0C3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 22),
              const _FieldLabel('提醒类型'),
              const SizedBox(height: 10),
              _buildTypeGrid(),
              const SizedBox(height: 18),
              _LabeledRow(
                label: '成员',
                child: _InputShell(
                  onTap: _showMemberPicker,
                  child: Row(
                    children: [
                      MemberAvatar(
                        name: memberName,
                        relation: memberRelation,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          memberName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _LabeledRow(
                label: '提醒标题',
                child: _TextInputShell(
                  controller: _titleController,
                  hintText: '请输入提醒标题',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),
              _buildDateTimeRow(),
              const SizedBox(height: 12),
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
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '不重复',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildNotifyRow(),
              const SizedBox(height: 12),
              _LabeledRow(
                label: '备注',
                child: _TextInputShell(
                  controller: _noteController,
                  hintText: '可填写准备事项',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 14),
              _buildSourceRow(),
              const SizedBox(height: 18),
              _buildPreviewCard(selectedType, memberName),
              const SizedBox(height: 20),
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
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.mintBg,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.add_box_outlined,
            color: AppColors.mintDeep,
            size: 34,
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '手动添加提醒',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 7),
              Text(
                '为家人创建清晰可靠的健康提醒',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 30,
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
          if (type != _types.last) const SizedBox(width: 8),
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
            child: _InputShell(
              onTap: _pickDate,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 21,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy/MM/dd').format(_scheduledAt),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '时间',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InputShell(
              onTap: _pickTime,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('HH:mm').format(_scheduledAt),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
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
        spacing: 10,
        runSpacing: 8,
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
        const SizedBox(
          width: 88,
          child: Text(
            '来源',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F3F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '手动创建',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(_ReminderType selectedType, String memberName) {
    final title = _titleController.text.trim().isEmpty
        ? '肺结节 CT 复查'
        : _titleController.text.trim();
    final note = _noteController.text.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.coralSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD7D8),
                  Color(0xFFFF9D9F),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.air_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coralSoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        selectedType.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.rose,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _PreviewMeta(
                      icon: Icons.access_time_rounded,
                      label: DateFormat('yyyy/MM/dd').format(_scheduledAt),
                    ),
                    _PreviewMeta(
                      icon: Icons.access_time_rounded,
                      label: DateFormat('HH:mm').format(_scheduledAt),
                    ),
                    _PreviewMeta(
                      icon: Icons.person_outline_rounded,
                      label: memberName,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  note.isEmpty ? '带上既往检查报告' : note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightOutline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: _saving ? null : _save,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 60,
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintDeep.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                _saving ? '创建中...' : '确认创建',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _saving ? null : _reset,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.mintDeep),
              ),
              child: const Text(
                '重置',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
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
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
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
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
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
      _titleController.text = '肺结节 CT 复查';
      _noteController.text = '带上既往检查报告';
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
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
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
        SizedBox(width: 88, child: _FieldLabel(label)),
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
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
    final color = selected ? AppColors.rose : type.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.roseSoft.withValues(alpha: 0.45)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.rose.withValues(alpha: 0.45)
                : AppColors.lightOutline,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: color, size: 23),
            const SizedBox(height: 5),
            Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
              size: 21,
              color: selected ? AppColors.mintDeep : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.mintDeep : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMeta extends StatelessWidget {
  const _PreviewMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
