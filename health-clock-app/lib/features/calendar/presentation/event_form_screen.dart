import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/models/health_event.dart';
import '../../../shared/widgets/app_cupertino_pickers.dart';
import '../../members/presentation/member_picker_field.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/event_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.prefill, this.event});

  /// 预填：来自 AI 解析或 OCR 候选
  final Map<String, dynamic>? prefill;

  /// 编辑模式：已存在的事件
  final HealthEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _eventType = 'follow_up';
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  String? _memberId;
  bool _saving = false;

  static const _typeOptions = [
    _EventTypeOption('follow_up', '复查', Icons.search_rounded, AppColors.rose),
    _EventTypeOption(
      'revisit',
      '复诊',
      Icons.medical_services_outlined,
      AppColors.careBlue,
    ),
    _EventTypeOption(
      'medication',
      '用药',
      Icons.medication_rounded,
      AppColors.mintDeep,
    ),
    _EventTypeOption(
      'checkup',
      '体检',
      Icons.medical_information_outlined,
      AppColors.warmAmber,
    ),
    _EventTypeOption(
      'monitoring',
      '监测',
      Icons.monitor_heart_outlined,
      AppColors.lavender,
    ),
    _EventTypeOption(
      'custom',
      '自定义',
      Icons.more_horiz_rounded,
      AppColors.textPrimary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    final e = widget.event;
    if (e != null) {
      _titleController.text = e.title;
      _descController.text = e.description ?? '';
      _eventType = e.eventType;
      _scheduledAt = e.scheduledAt.toLocal();
      _isAllDay = e.isAllDay;
      _memberId = e.memberId;
      return;
    }

    final p = widget.prefill;
    if (p != null) {
      _titleController.text = (p['event_title'] ?? p['title'] ?? '') as String;
      _descController.text = (p['description'] as String?) ?? '';
      _eventType = (p['event_type'] as String?) ?? 'follow_up';
      final sched = p['scheduled_at'];
      if (sched is String) _scheduledAt = DateTime.parse(sched).toLocal();
      _isAllDay = (p['is_all_day'] as bool?) ?? false;
      _memberId = p['member_id'] as String?;
    }
    _memberId ??= ref.read(currentMemberIdProvider);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    ref.listen(currentMemberIdProvider, (_, next) {
      if (_memberId == null && next != null) {
        setState(() => _memberId = next);
      }
    });

    final isEdit = widget.event != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.screenMargin,
                  AppStyles.spacingS,
                  AppStyles.screenMargin,
                  0,
                ),
                child: _TopBar(
                  title: isEdit ? '编辑提醒' : '新建提醒',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppStyles.screenMargin,
                    AppStyles.spacingM,
                    AppStyles.screenMargin,
                    112,
                  ),
                  children: [
                    _SectionCard(
                      children: [
                        if (!isEdit) ...[
                          MemberPickerField(
                            value: _memberId,
                            onChanged: (v) => setState(() => _memberId = v),
                          ),
                          const SizedBox(height: AppStyles.spacingM),
                        ],
                        _FormTextField(
                          controller: _titleController,
                          label: '标题',
                          hintText: '请输入提醒标题',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? '请输入标题'
                                  : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingM),
                    const _SectionTitle('提醒类型'),
                    const SizedBox(height: AppStyles.spacingS),
                    _TypeSelector(
                      options: _typeOptions,
                      selected: _eventType,
                      onSelected: (value) => setState(() => _eventType = value),
                    ),
                    const SizedBox(height: AppStyles.spacingM),
                    _SectionCard(
                      children: [
                        _SwitchRow(
                          label: '全天',
                          value: _isAllDay,
                          onChanged: (value) =>
                              setState(() => _isAllDay = value),
                        ),
                        const Divider(
                          height: AppStyles.spacingM,
                          color: AppColors.lightDivider,
                        ),
                        _PickerRow(
                          label: '时间',
                          value: _isAllDay
                              ? DateFormat('yyyy年M月d日').format(_scheduledAt)
                              : DateFormat('yyyy年M月d日 HH:mm')
                                  .format(_scheduledAt),
                          onTap: _pickDateTime,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spacingM),
                    _FormTextField(
                      controller: _descController,
                      label: '描述（可选）',
                      hintText: '补充准备事项或说明',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              _BottomSaveButton(
                saving: _saving,
                label: isEdit ? '保存' : '创建',
                onTap: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    if (_isAllDay) {
      final date = await AppCupertinoPickers.date(
        context: context,
        initialDate: _scheduledAt,
        minimumDate: DateTime(2020),
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
      return;
    }

    final dateTime = await AppCupertinoPickers.dateTime(
      context: context,
      initialDateTime: _scheduledAt,
      minimumDate: DateTime(2020),
      maximumDate: DateTime(2100),
      title: '选择提醒时间',
    );
    if (dateTime == null) return;
    setState(() => _scheduledAt = dateTime);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final memberId = widget.event?.memberId ?? _memberId;
    if (memberId == null || memberId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择成员')));
      return;
    }
    setState(() => _saving = true);
    try {
      final notifier = ref.read(eventListProvider.notifier);
      HealthEvent event;
      if (widget.event != null) {
        event = await notifier.updateEvent(widget.event!.id, {
          'title': _titleController.text.trim(),
          'description': _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          'event_type': _eventType,
          'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
          'is_all_day': _isAllDay,
        });
      } else {
        final data = EventCreate(
          memberId: memberId,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          eventType: _eventType,
          scheduledAt: _scheduledAt,
          isAllDay: _isAllDay,
          repeatRule: _parseStringMap(widget.prefill?['repeat_rule']),
          notifyOffsets: (widget.prefill?['notify_offsets'] as List?)
              ?.whereType<num>()
              .map((n) => n.toInt())
              .toList(),
          sourceType: (widget.prefill?['source_type'] as String?) ??
              ((widget.prefill != null) ? 'ai_text' : 'manual'),
          sourceText: widget.prefill?['source_text'] as String?,
          aiConfidence: (widget.prefill?['confidence'] as num?)?.toDouble(),
        );
        event = await notifier.createEvent(data);
      }

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
      Navigator.of(context).pop(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.event == null ? '创建成功' : '已保存')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic>? _parseStringMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppStyles.minTouchTarget,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: AppStyles.iconTouchTarget,
              minHeight: AppStyles.iconTouchTarget,
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Text(
            title,
            style: AppStyles.headline.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppStyles.sectionTitle.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: AppStyles.subhead.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        labelStyle: AppStyles.caption1.copyWith(color: AppColors.textTertiary),
        hintStyle: AppStyles.subhead.copyWith(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spacingM,
          vertical: AppStyles.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: const BorderSide(color: AppColors.mintDeep),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_EventTypeOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: _TypeTile(
              option: option,
              selected: option.value == selected,
              onTap: () => onSelected(option.value),
            ),
          ),
          if (option != options.last) const SizedBox(width: AppStyles.spacingS),
        ],
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _EventTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  option.color.withValues(alpha: 0.12),
                  Colors.white,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(
            color: selected
                ? option.color.withValues(alpha: 0.45)
                : AppColors.lightOutline,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, color: option.color, size: 20),
            const SizedBox(height: AppStyles.spacingXs),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption1.copyWith(
                color: option.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppStyles.subhead.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppStyles.minTouchTarget,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingXs),
                  Text(
                    value,
                    style: AppStyles.subhead.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSaveButton extends StatelessWidget {
  const _BottomSaveButton({
    required this.saving,
    required this.label,
    required this.onTap,
  });

  final bool saving;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingS,
        AppStyles.screenMargin,
        AppStyles.spacingS + bottomPadding * 0.35,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightDivider,
            width: AppStyles.dividerThin,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Container(
          height: AppStyles.primaryButtonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF34C58A), Color(0xFF16995C)],
            ),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.mintDeep.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, AppStyles.spacingS),
              ),
            ],
          ),
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppStyles.subhead.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _EventTypeOption {
  const _EventTypeOption(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}
