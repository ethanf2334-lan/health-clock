import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../../../shared/models/health_event.dart';
import '../../members/presentation/member_picker_field.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/event_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  /// 预填：来自 AI 解析或 OCR 候选
  final Map<String, dynamic>? prefill;

  /// 编辑模式：已存在的事件
  final HealthEvent? event;

  const EventFormScreen({super.key, this.prefill, this.event});

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

  final _typeOptions = const [
    {'value': 'follow_up', 'label': '复查'},
    {'value': 'revisit', 'label': '复诊'},
    {'value': 'checkup', 'label': '体检'},
    {'value': 'medication', 'label': '用药'},
    {'value': 'monitoring', 'label': '监测'},
    {'value': 'custom', 'label': '自定义'},
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
      if (sched is String) {
        _scheduledAt = DateTime.parse(sched).toLocal();
      }
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
    final isEdit = widget.event != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑提醒' : '新建提醒'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isEdit)
              MemberPickerField(
                value: _memberId,
                onChanged: (v) => setState(() => _memberId = v),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '标题'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入标题' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              decoration: const InputDecoration(labelText: '类型'),
              items: _typeOptions
                  .map(
                    (o) => DropdownMenuItem<String>(
                      value: o['value'],
                      child: Text(o['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _eventType = v);
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('全天'),
              value: _isAllDay,
              onChanged: (v) => setState(() => _isAllDay = v),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('时间'),
              subtitle: Text(
                _isAllDay
                    ? DateFormat('yyyy-MM-dd').format(_scheduledAt)
                    : DateFormat('yyyy-MM-dd HH:mm').format(_scheduledAt),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: '描述（可选）'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? '保存' : '创建'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    DateTime result = DateTime(
      date.year,
      date.month,
      date.day,
      _scheduledAt.hour,
      _scheduledAt.minute,
    );
    if (!_isAllDay) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      );
      if (time == null) return;
      result =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    setState(() => _scheduledAt = result);
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
          sourceType: (widget.prefill?['source_type'] as String?) ??
              ((widget.prefill != null) ? 'ai_text' : 'manual'),
          sourceText: widget.prefill?['source_text'] as String?,
          aiConfidence: (widget.prefill?['confidence'] as num?)?.toDouble(),
        );
        event = await notifier.createEvent(data);
      }

      // 尝试调度本地通知（失败不影响主流程）
      try {
        await NotificationService().scheduleNotification(
          id: event.id.hashCode & 0x7FFFFFFF,
          title: event.title,
          body: '健康时钟提醒',
          scheduledDate: event.scheduledAt.toLocal(),
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
}
