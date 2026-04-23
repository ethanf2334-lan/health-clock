import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_input_provider.dart';

class AIInputScreen extends ConsumerStatefulWidget {
  const AIInputScreen({super.key});

  @override
  ConsumerState<AIInputScreen> createState() => _AIInputScreenState();
}

class _AIInputScreenState extends ConsumerState<AIInputScreen> {
  final _textController = TextEditingController();
  bool _isProcessing = false;

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
            const Text(
              '用自然语言描述健康提醒',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '例如："甲状腺 3 个月后复查"、"明天带妈妈去医院复诊"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '请输入提醒内容...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              enabled: !_isProcessing,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 16),
            Expanded(
              child: _buildResultSection(),
            ),
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

        final event = result['parsed_event'];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      '解析结果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildResultItem('标题', event['event_title']),
                _buildResultItem('类型', _getEventTypeLabel(event['event_type'])),
                _buildResultItem(
                  '时间',
                  DateTime.parse(event['scheduled_at']).toString().substring(0, 16),
                ),
                _buildResultItem(
                  '置信度',
                  '${(event['confidence'] * 100).toStringAsFixed(0)}%',
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
                        Icon(Icons.warning_amber, size: 16, color: Colors.orange),
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
                        onPressed: () {
                          // TODO: 导航到创建提醒页面，填充解析结果
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('功能开发中')),
                          );
                        },
                        child: const Text('创建提醒'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
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

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(String type) {
    const typeMap = {
      'follow_up': '复查',
      'revisit': '复诊',
      'checkup': '体检',
      'medication': '用药',
      'monitoring': '监测',
      'custom': '自定义',
    };
    return typeMap[type] ?? type;
  }

  Future<void> _handleSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提醒内容')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref.read(aIParseResultProvider.notifier).parseText(text);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
