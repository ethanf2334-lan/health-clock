import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../../../shared/models/health_event.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String id;
  const EventDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(eventDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('提醒详情')),
      body: detailAsync.when(
        data: (event) => _buildBody(context, ref, event),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HealthEvent event) {
    final isDone = event.status == 'completed';
    final scheduled = event.scheduledAt.toLocal();
    final timeText = event.isAllDay
        ? DateFormat('yyyy-MM-dd').format(scheduled)
        : DateFormat('yyyy-MM-dd HH:mm').format(scheduled);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          event.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
          ),
        ),
        const SizedBox(height: 16),
        _row('类型', _typeLabel(event.eventType)),
        _row('时间', timeText),
        _row('状态', _statusLabel(event.status)),
        if (event.description != null && event.description!.isNotEmpty)
          _row('描述', event.description!),
        _row('来源', _sourceLabel(event.sourceType)),
        if (event.sourceText != null && event.sourceText!.isNotEmpty)
          _row('原始输入', event.sourceText!),
        if (event.aiConfidence != null)
          _row(
            'AI 置信度',
            '${(event.aiConfidence! * 100).toStringAsFixed(0)}%',
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (!isDone)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('标记完成'),
                  onPressed: () async {
                    await ref
                        .read(eventListProvider.notifier)
                        .completeEvent(event.id);
                    await NotificationService()
                        .cancelNotification(event.id.hashCode & 0x7FFFFFFF);
                    ref.invalidate(eventDetailProvider(event.id));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已完成')),
                      );
                    }
                  },
                ),
              ),
            if (!isDone) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('编辑'),
                onPressed: () async {
                  await context.push('/events/${event.id}/edit', extra: event);
                  ref.invalidate(eventDetailProvider(event.id));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('删除', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定删除这条提醒吗？'),
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
              await ref.read(eventListProvider.notifier).deleteEvent(event.id);
              await NotificationService()
                  .cancelNotification(event.id.hashCode & 0x7FFFFFFF);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
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

  String _statusLabel(String s) =>
      {'pending': '待完成', 'completed': '已完成', 'cancelled': '已取消'}[s] ?? s;

  String _sourceLabel(String s) =>
      {
        'ai_text': 'AI 文本',
        'ai_voice': 'AI 语音',
        'ai_document': 'AI 文档',
        'manual': '手动',
      }[s] ??
      s;
}
