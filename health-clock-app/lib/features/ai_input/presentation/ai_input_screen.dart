import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../calendar/presentation/event_form_screen.dart';
import '../../members/presentation/member_picker_field.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/ai_input_provider.dart';

class AIInputScreen extends ConsumerStatefulWidget {
  const AIInputScreen({super.key});

  @override
  ConsumerState<AIInputScreen> createState() => _AIInputScreenState();
}

class _AIInputScreenState extends ConsumerState<AIInputScreen> {
  final _textController = TextEditingController();
  bool _isProcessing = false;
  String? _memberId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 创建提醒'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemberPickerField(
              value: _memberId,
              onChanged: (v) => setState(() => _memberId = v),
              required: false,
              label: '成员（可选）',
            ),
            const SizedBox(height: 12),
            const Text(
              '用自然语言描述健康提醒',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '例如："甲状腺 3 个月后复查"、"明天带妈妈去医院复诊"',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '请输入提醒内容...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              enabled: !_isProcessing,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handleSubmit,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('AI 解析'),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildResultSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    final resultAsync = ref.watch(aIParseResultProvider);

    return resultAsync.when(
      data: (result) {
        if (result == null) {
          return Center(
            child: Text(
              '输入内容后点击"AI 解析"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        final event = result['parsed_event'] as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('解析结果',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildItem('标题', event['event_title'] as String),
                  _buildItem('类型', _typeLabel(event['event_type'] as String)),
                  _buildItem(
                    '时间',
                    DateFormat('yyyy-MM-dd HH:mm').format(
                      DateTime.parse(event['scheduled_at'] as String).toLocal(),
                    ),
                  ),
                  _buildItem(
                    '置信度',
                    '${((event['confidence'] as num) * 100).toStringAsFixed(0)}%',
                  ),
                  if (event['needs_confirmation'] == true)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('建议确认时间和内容'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _textController.clear();
                            ref.invalidate(aIParseResultProvider);
                          },
                          child: const Text('重新输入'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _gotoConfirm(event),
                          child: const Text('确认创建'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('解析失败: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
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

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入提醒内容')));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(aIParseResultProvider.notifier)
          .parseText(text, memberId: _memberId);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _gotoConfirm(Map<String, dynamic> event) async {
    if (_memberId == null || _memberId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择成员')),
      );
      return;
    }
    final prefill = {
      ...event,
      'member_id': _memberId,
      'source_text': _textController.text.trim(),
    };
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventFormScreen(prefill: prefill),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).pop();
    }
  }
}
