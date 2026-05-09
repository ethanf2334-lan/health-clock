import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_styles.dart';
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
    '每天晚上8点提醒吃药',
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
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.spacingM,
                  AppStyles.spacingS,
                  AppStyles.spacingM,
                  AppStyles.spacingS,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(width: AppStyles.spacingS),
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
                        fontSize: AppStyles.footnote.fontSize,
                      ),
                    ),
                    const SizedBox(width: AppStyles.spacingXs),
                    const Icon(Icons.keyboard_arrow_up),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!widget.compact) return _buildDesignedSheet();

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

  Widget _buildDesignedSheet() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFEFE),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: AppStyles.spacingXs),
            Container(
              width: 48,
              height: AppStyles.spacingXs,
              decoration: BoxDecoration(
                color: const Color(0xFFB8C0C3),
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppStyles.spacingM,
                AppStyles.spacingS,
                AppStyles.spacingM,
                0,
              ),
              child: _buildDesignedHeader(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppStyles.spacingM,
                AppStyles.spacingXs,
                AppStyles.spacingM,
                0,
              ),
              child: _buildExamples(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.spacingM,
                  AppStyles.spacingXs,
                  AppStyles.spacingM,
                  0,
                ),
                child: _buildDesignedHistory(),
              ),
            ),
            _buildDesignedComposerArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignedHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF1FF),
                Color(0xFFDCE7FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.careBlue.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, AppStyles.spacingXs),
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'AI',
                style: TextStyle(
                  color: AppColors.careBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Positioned(
                right: 10,
                top: 9,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.careBlue,
                  size: 15,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 15,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.careBlue,
                  size: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 创建提醒',
                style: AppStyles.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppStyles.spacingXs),
              Text(
                '用一句话描述你想提醒的健康事项',
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
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildDesignedHistory() {
    if (_entries.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDesignedEmptyState(),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.zero,
      itemCount: _entries.length,
      itemBuilder: (_, index) =>
          _buildDesignedChatEntry(_entries[_entries.length - 1 - index]),
    );
  }

  Widget _buildDesignedEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border:
            Border.all(color: AppColors.lightOutline.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.amberSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warmAmber.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.warmAmber,
              size: 16,
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: Text(
              '输入一句话，我会帮你整理成可确认的健康提醒。',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignedChatEntry(_AIChatEntry entry) {
    if (entry.role == _AIChatRole.user) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
        child: _buildDesignedUserBubble(entry.text),
      );
    }
    if (entry.event != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDesignedAssistantText(
              '好的，已为您解析出以下提醒信息，请确认是否正确：',
            ),
            const SizedBox(height: AppStyles.spacingM),
            _buildDraftCard(entry.event!),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.spacingS),
      child: _buildDesignedAssistantText(entry.text),
    );
  }

  Widget _buildDesignedUserBubble(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 330),
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.spacingM,
              vertical: AppStyles.spacingS,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5EC),
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintDeep.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, AppStyles.spacingS),
                ),
              ],
            ),
            child: Text(
              text,
              style: AppStyles.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        const _SmallAvatar(),
      ],
    );
  }

  Widget _buildDesignedAssistantText(String text) {
    final isError = text.startsWith('暂时没整理出来');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SparkAvatar(size: 36),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.spacingM,
              vertical: AppStyles.spacingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              border: Border.all(
                color: isError ? AppColors.coralSoft : AppColors.lightOutline,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, AppStyles.spacingS),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppStyles.footnote.fontSize,
                fontWeight: FontWeight.w600,
                color: isError ? AppColors.danger : AppColors.textPrimary,
                height: AppStyles.subhead.height,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignedComposerArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingXs,
        AppStyles.spacingM,
        AppStyles.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, AppStyles.spacingS),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 1,
                      enabled: !_isProcessing && !_saving,
                      style: AppStyles.subhead.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(fromVoice: false),
                      decoration: const InputDecoration(
                        hintText: '继续补充或修改提醒...',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.fromLTRB(16, 12, 8, 12),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (_isProcessing || _saving) ? null : _toggleListening,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: AppStyles.spacingXs),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightOutline),
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_none,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacingS),
          InkWell(
            onTap: (_isProcessing || _saving)
                ? null
                : () => _handleSubmit(fromVoice: false),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            child: Container(
              width: 56,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7C8CFF),
                    Color(0xFF8454EE),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lavender.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, AppStyles.spacingS),
                  ),
                ],
              ),
              child: _isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
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

    if (!widget.compact) {
      return SizedBox(
        height: 32,
        child: ListView.separated(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: _examples.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppStyles.spacingS),
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
            style: AppStyles.subhead.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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
    if (!widget.compact) return _buildDesignedDraftCard(event);

    final scheduledAt = _parseScheduledAt(event);
    final confidence = (event['confidence'] as num?)?.toDouble();
    final needsConfirmation = event['needs_confirmation'] == true;
    final title = (event['event_title'] ?? '健康提醒').toString();
    final type = _typeLabel((event['event_type'] ?? 'custom').toString());
    final repeat = _repeatLabel(_parseStringMap(event['repeat_rule']));
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
                style: const TextStyle(fontWeight: FontWeight.w600),
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

  Widget _buildDesignedDraftCard(Map<String, dynamic> event) {
    final scheduledAt = _parseScheduledAt(event);
    final title = (event['event_title'] ?? '健康提醒').toString();
    final typeLabel =
        _typeLabel((event['event_type'] ?? 'medication').toString());
    final repeat = _repeatLabel(_parseStringMap(event['repeat_rule']));
    final time = scheduledAt == null
        ? (repeat == null ? '每天 20:00' : '$repeat 20:00')
        : _designedTimeLabel(scheduledAt, repeat);
    final note = (event['description'] as String?)?.trim();
    final memberName = _draftMemberName(event);

    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingS),
      margin: const EdgeInsets.only(right: AppStyles.spacingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFBF9FF),
            Color(0xFFF8FCFF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: const Color(0xFFDCD8FF)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, AppStyles.spacingXs),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '待确认',
                  style: AppStyles.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFD8D2FF)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: Color(0xFF7B6CF6),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AI 解析',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7B6CF6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingS),
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingS),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 14,
                  offset: const Offset(0, AppStyles.spacingXs),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.roseSoft,
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusM,
                              ),
                            ),
                            child: const Icon(
                              Icons.medication_rounded,
                              color: AppColors.rose,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: AppStyles.spacingS),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppStyles.spacingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppStyles.spacingS,
                              vertical: AppStyles.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.roseSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              typeLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.rose,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.spacingS),
                      _DraftInfoGrid(
                        items: [
                          _DraftInfoItem(
                            icon: Icons.access_time_rounded,
                            label: '时间',
                            value: time,
                          ),
                          _DraftInfoItem(
                            icon: Icons.person_outline_rounded,
                            label: '成员',
                            value: memberName,
                          ),
                          _DraftInfoItem(
                            icon: Icons.event_note_outlined,
                            label: '备注',
                            value:
                                (note == null || note.isEmpty) ? '未填写' : note,
                          ),
                          const _DraftInfoItem(
                            icon: Icons.medical_information_outlined,
                            label: '来源',
                            value: 'AI 解析',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _DesignedActionButton(
                  icon: Icons.edit_outlined,
                  label: '改',
                  primary: false,
                  onTap: _saving ? null : () => _editDraft(event),
                ),
                const SizedBox(width: AppStyles.spacingS),
                _DesignedActionButton(
                  icon: _saving ? null : Icons.check_rounded,
                  label: _saving ? '创建中' : '确认',
                  primary: true,
                  onTap: _saving ? null : () => _confirmCreate(event),
                ),
              ],
            ),
          ),
        ],
      ),
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
          .parseText(text, memberId: _memberId, memberName: _currentMemberName);
      final parsedEvent = _parseStringMap(result['parsed_event']);
      if (parsedEvent == null) {
        throw const FormatException('AI 没有返回可用的提醒草稿');
      }
      final event = {
        ...parsedEvent,
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
              repeatRule: _parseStringMap(event['repeat_rule']),
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

  String? get _currentMemberName {
    final member = ref.read(currentMemberProvider);
    return member?.name.trim().isEmpty == false ? member!.name.trim() : null;
  }

  String _draftMemberName(Map<String, dynamic> event) {
    final fromEvent = event['member_name']?.toString().trim();
    if (fromEvent != null && fromEvent.isNotEmpty) return fromEvent;
    return _currentMemberName ?? '当前成员';
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

  Map<String, dynamic>? _parseStringMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
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

  String _designedTimeLabel(DateTime scheduledAt, String? repeat) {
    final time = DateFormat('HH:mm').format(scheduledAt);
    if (repeat != null) return '$repeat $time';
    return DateFormat('M月d日 HH:mm').format(scheduledAt);
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spacingS,
          vertical: AppStyles.spacingXs,
        ),
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
            fontSize: 11,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SparkAvatar extends StatelessWidget {
  const _SparkAvatar({this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB9A8FF),
            Color(0xFF6B63F6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.roseSoft,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Text('👩🏻', style: TextStyle(fontSize: 15)),
    );
  }
}

class _DraftInfoItem {
  const _DraftInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _DraftInfoGrid extends StatelessWidget {
  const _DraftInfoGrid({required this.items});

  final List<_DraftInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppStyles.spacingS) / 2;
        return Wrap(
          spacing: AppStyles.spacingS,
          runSpacing: AppStyles.spacingS,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _DraftInfoTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _DraftInfoTile extends StatelessWidget {
  const _DraftInfoTile({required this.item});

  final _DraftInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 13, color: AppColors.mintDeep),
          if (item.label.isNotEmpty) ...[
            const SizedBox(width: AppStyles.spacingXs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption1.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                height: 1.05,
              ),
            ),
          ],
          const SizedBox(width: AppStyles.spacingXs),
          Expanded(
            child: Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppStyles.caption1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignedActionButton extends StatelessWidget {
  const _DesignedActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 15,
            color: primary ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: AppStyles.spacingXs),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: AppStyles.footnote.fontSize,
            fontWeight: FontWeight.w600,
            color: primary ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: 34,
        constraints: BoxConstraints(minWidth: primary ? 68 : 54),
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF37C58D),
                    Color(0xFF22A868),
                  ],
                )
              : null,
          color: primary ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          border: primary ? null : Border.all(color: AppColors.lightOutline),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.mintDeep.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, AppStyles.spacingXs),
                  ),
                ]
              : null,
        ),
        child: child,
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
