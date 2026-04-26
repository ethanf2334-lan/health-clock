import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/models/health_event.dart';
import '../../calendar/presentation/event_form_screen.dart';
import '../../calendar/providers/event_provider.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/ai_input_provider.dart';

class AIQuickCreatePanel extends ConsumerStatefulWidget {
  const AIQuickCreatePanel({
    super.key,
    this.compact = false,
    this.onCreated,
  });

  final bool compact;
  final ValueChanged<HealthEvent>? onCreated;

  @override
  ConsumerState<AIQuickCreatePanel> createState() => _AIQuickCreatePanelState();
}

class _AIQuickCreatePanelState extends ConsumerState<AIQuickCreatePanel> {
  static const _examples = [
    '甲状腺三个月后复查',
    '两周后复查肺结节 CT',
    '每天晚上8点提醒妈妈吃药',
  ];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final SpeechToText _speech = SpeechToText();
  final List<_AIChatEntry> _entries = [];

  bool _isProcessing = false;
  bool _isListening = false;
  bool _speechReady = false;
  bool _speechInitAttempted = false;
  bool _saving = false;
  bool _expanded = false;
  String? _memberId;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.compact;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _speech.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    ref.listen(currentMemberIdProvider, (_, next) {
      if (_memberId != next) {
        setState(() => _memberId = next);
      }
    });

    if (widget.compact && !_expanded) {
      final colorScheme = Theme.of(context).colorScheme;
      return SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: _panelDecoration(context),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = true);
                _scrollToBottom();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI 创建提醒',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      '点这里输入',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_up),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final history = _buildHistory(constraints.maxHeight);
        return Column(
          mainAxisSize: widget.compact ? MainAxisSize.max : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: _buildHeader(),
              )
            else
              _buildHeader(),
            const SizedBox(height: 6),
            if (widget.compact)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: history,
                ),
              )
            else
              Flexible(child: history),
            _buildComposerArea(),
          ],
        );
      },
    );

    if (!widget.compact) return content;

    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.padding.top - 72;
    final panelHeight = math.min(
      320.0,
      math.max(260.0, availableHeight * 0.42),
    );

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: _panelDecoration(context),
        child: SizedBox(
          height: math.min(panelHeight, availableHeight),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: _panelColor(colorScheme),
      border: Border(
        top: BorderSide(color: colorScheme.outlineVariant),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.lavender.withValues(alpha: 0.14),
          blurRadius: 18,
          offset: const Offset(0, -3),
        ),
      ],
    );
  }

  Color _panelColor(ColorScheme colorScheme) {
    return Color.alphaBlend(
      AppColors.careBlue.withValues(alpha: 0.16),
      colorScheme.surface,
    );
  }

  Color _historyColor(ColorScheme colorScheme) {
    return Color.alphaBlend(
      colorScheme.surface.withValues(alpha: 0.74),
      _panelColor(colorScheme),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 17,
            color: AppColors.lavender,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'AI 创建提醒',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (_entries.isNotEmpty)
          IconButton(
            tooltip: '清空记录',
            visualDensity: VisualDensity.compact,
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        if (widget.compact)
          IconButton(
            tooltip: '收起',
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => _expanded = false),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        if (_isProcessing)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildHistory(double maxHeight) {
    if (_entries.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _historyColor(colorScheme),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppColors.lavender,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '像聊天一样告诉我想创建什么健康提醒。',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildExamples(wrap: true),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _entries.length,
      itemBuilder: (_, index) =>
          _buildChatBubble(_entries[_entries.length - 1 - index]),
    );
  }

  void _clearHistory() {
    if (_entries.isEmpty) return;
    setState(_entries.clear);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1200),
          content: Text('已清空 AI 创建记录'),
        ),
      );
  }

  Widget _buildChatBubble(_AIChatEntry entry) {
    final align = entry.role == _AIChatRole.user
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final color = entry.role == _AIChatRole.user
        ? Theme.of(context).colorScheme.primary
        : _historyColor(Theme.of(context).colorScheme);
    final textColor = entry.role == _AIChatRole.user
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: entry.role == _AIChatRole.error
              ? Border.all(color: Theme.of(context).colorScheme.error)
              : null,
        ),
        child: entry.event == null
            ? Text(entry.text, style: TextStyle(color: textColor))
            : _buildDraftCard(entry.event!),
      ),
    );
  }

  Widget _buildExamples({bool wrap = false}) {
    if (wrap) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _examples.map((example) {
          return _ExampleChip(
            label: example,
            enabled: !_isProcessing && !_saving,
            onTap: () => _useExample(example),
          );
        }).toList(),
      );
    }

    return SizedBox(
      height: 30,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: _examples.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final example = _examples[index];
          return _ExampleChip(
            label: example,
            enabled: !_isProcessing && !_saving,
            onTap: () => _useExample(example),
          );
        },
      ),
    );
  }

  void _useExample(String example) {
    _textController.text = example;
    _textController.selection = TextSelection.collapsed(
      offset: example.length,
    );
    _handleSubmit(fromVoice: false);
  }

  Widget _buildComposerArea() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.compact) ...[
            _buildExamples(),
            const SizedBox(height: 8),
          ],
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '发一条健康提醒需求...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            minLines: 1,
            maxLines: widget.compact ? 1 : 4,
            enabled: !_isProcessing && !_saving,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _handleSubmit(fromVoice: false),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: _isListening ? '停止语音输入' : '语音输入',
          onPressed: (_isProcessing || _saving) ? null : _toggleListening,
          icon: Icon(_isListening ? Icons.stop : Icons.mic_none),
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          tooltip: '发送',
          onPressed: (_isProcessing || _saving)
              ? null
              : () => _handleSubmit(fromVoice: false),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> event) {
    final scheduledAt = _parseScheduledAt(event);
    final confidence = (event['confidence'] as num?)?.toDouble();
    final needsConfirmation = event['needs_confirmation'] == true;
    final title = (event['event_title'] ?? '健康提醒').toString();
    final type = _typeLabel((event['event_type'] ?? 'custom').toString());
    final repeat = _repeatLabel(event['repeat_rule'] as Map<String, dynamic>?);
    final time = scheduledAt == null
        ? '待确认'
        : DateFormat('M月d日 HH:mm').format(scheduledAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.event_available, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          [time, type, if (repeat != null) repeat].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        if (confidence != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '置信度 ${(confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        if (needsConfirmation) ...[
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.warning_amber, size: 16, color: Colors.orange),
              SizedBox(width: 6),
              Expanded(child: Text('建议确认时间、成员和重复规则')),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(52, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: _saving ? null : () => _editDraft(event),
              child: const Text('修改'),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(76, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: _saving ? null : () => _confirmCreate(event),
              child: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('确认'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSubmit({required bool fromVoice}) async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提醒内容')),
      );
      return;
    }

    _textController.clear();
    setState(() {
      _isProcessing = true;
      _entries.add(_AIChatEntry.user(text));
    });
    _scrollToBottom();

    try {
      final result = await ref
          .read(aIParseResultProvider.notifier)
          .parseText(text, memberId: _memberId);
      final event = {
        ...(result['parsed_event'] as Map<String, dynamic>),
        '_source_text': text,
        '_source_type': fromVoice ? 'ai_voice' : 'ai_text',
      };
      if (!mounted) return;
      setState(() {
        _entries.add(_AIChatEntry.assistant(event));
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _entries.add(_AIChatEntry.error('暂时没整理出来：$e'));
      });
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) return;

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'zh_CN',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        autoPunctuation: true,
      ),
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        });
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _handleSubmit(fromVoice: true);
        }
      },
    );
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    if (_speechInitAttempted && !_speechReady) {
      _showSpeechUnavailable();
      return false;
    }

    _speechInitAttempted = true;
    final ready = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('语音输入失败：${error.errorMsg}')),
        );
      },
    );
    if (!mounted) return false;
    setState(() => _speechReady = ready);
    if (!ready) _showSpeechUnavailable();
    return ready;
  }

  void _showSpeechUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音识别不可用，请检查麦克风和语音识别权限')),
    );
  }

  Future<void> _confirmCreate(Map<String, dynamic> event) async {
    final memberId = _memberId;
    if (memberId == null || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择成员')),
      );
      return;
    }
    final scheduledAt = _parseScheduledAt(event);
    if (scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先修改并确认提醒时间')),
      );
      await _editDraft(event);
      return;
    }

    setState(() => _saving = true);
    try {
      final created = await ref.read(eventListProvider.notifier).createEvent(
            EventCreate(
              memberId: memberId,
              title: (event['event_title'] ?? '健康提醒').toString(),
              description: event['description'] as String?,
              eventType: (event['event_type'] ?? 'custom').toString(),
              scheduledAt: scheduledAt,
              isAllDay: (event['is_all_day'] as bool?) ?? false,
              repeatRule: event['repeat_rule'] as Map<String, dynamic>?,
              notifyOffsets: _parseNotifyOffsets(event['notify_offsets']),
              sourceType: (event['_source_type'] as String?) ?? 'ai_text',
              sourceText: event['_source_text'] as String?,
              aiConfidence: (event['confidence'] as num?)?.toDouble(),
            ),
          );

      try {
        await NotificationService().scheduleEventNotification(
          id: created.id.hashCode & 0x7FFFFFFF,
          title: created.title,
          scheduledDate: created.scheduledAt.toLocal(),
          repeatRule: created.repeatRule,
          payload: 'event:${created.id}',
        );
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _entries.add(_AIChatEntry.assistantText('已创建：${created.title}'));
        if (widget.compact) _expanded = false;
      });
      widget.onCreated?.call(created);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1200),
          content: Text('提醒已创建'),
        ),
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

  Future<void> _editDraft(Map<String, dynamic> event) async {
    final prefill = {
      ...event,
      if (_memberId != null) 'member_id': _memberId,
      'source_text': event['_source_text'],
      'source_type': event['_source_type'],
    };
    final result = await Navigator.of(context).push<HealthEvent>(
      MaterialPageRoute(
        builder: (_) => EventFormScreen(prefill: prefill),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _entries.add(_AIChatEntry.assistantText('已创建：${result.title}'));
        if (widget.compact) _expanded = false;
      });
      widget.onCreated?.call(result);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  DateTime? _parseScheduledAt(Map<String, dynamic> event) {
    final value = event['scheduled_at'];
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  List<int>? _parseNotifyOffsets(dynamic value) {
    if (value is! List) return null;
    return value.whereType<num>().map((n) => n.toInt()).toList();
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
}

class _ExampleChip extends StatelessWidget {
  const _ExampleChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

enum _AIChatRole { user, assistant, error }

class _AIChatEntry {
  const _AIChatEntry._(this.role, this.text, this.event);

  factory _AIChatEntry.user(String text) =>
      _AIChatEntry._(_AIChatRole.user, text, null);

  factory _AIChatEntry.assistant(Map<String, dynamic> event) =>
      _AIChatEntry._(_AIChatRole.assistant, '', event);

  factory _AIChatEntry.assistantText(String text) =>
      _AIChatEntry._(_AIChatRole.assistant, text, null);

  factory _AIChatEntry.error(String text) =>
      _AIChatEntry._(_AIChatRole.error, text, null);

  final _AIChatRole role;
  final String text;
  final Map<String, dynamic>? event;
}
