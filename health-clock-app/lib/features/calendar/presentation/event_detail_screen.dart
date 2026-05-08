import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/models/health_event.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(eventDetailProvider(id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: detailAsync.when(
          data: (event) => _buildBody(context, ref, event),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              '加载失败，请稍后重试',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HealthEvent event) {
    final isDone = event.status == 'completed';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppStyles.screenMargin,
            AppStyles.spacingS,
            AppStyles.screenMargin,
            0,
          ),
          child: _TopBar(onBack: () => Navigator.of(context).maybePop()),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppStyles.screenMargin,
              AppStyles.spacingM,
              AppStyles.screenMargin,
              isDone ? 112 : 120,
            ),
            children: [
              _HeroCard(
                event: event,
                typeLabel: _typeLabel(event.eventType),
                typeIcon: _typeIcon(event.eventType),
                typeColor: _typeColor(event.eventType),
              ),
              const SizedBox(height: AppStyles.spacingM),
              _InfoCard(
                rows: [
                  _DetailRowData(
                    icon: Icons.schedule_rounded,
                    label: event.isAllDay ? '全天提醒' : '提醒时间',
                    value: _timeText(event),
                  ),
                  _DetailRowData(
                    icon: Icons.flag_outlined,
                    label: '状态',
                    value: _statusLabel(event.status),
                  ),
                  _DetailRowData(
                    icon: Icons.auto_awesome_rounded,
                    label: '来源',
                    value: _sourceLabel(event.sourceType),
                  ),
                  if (_repeatLabel(event.repeatRule) != null)
                    _DetailRowData(
                      icon: Icons.sync_rounded,
                      label: '重复',
                      value: _repeatLabel(event.repeatRule)!,
                    ),
                  if (event.aiConfidence != null)
                    _DetailRowData(
                      icon: Icons.insights_rounded,
                      label: 'AI 置信度',
                      value:
                          '${(event.aiConfidence! * 100).toStringAsFixed(0)}%',
                    ),
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    _DetailRowData(
                      icon: Icons.event_note_outlined,
                      label: '备注',
                      value: event.description!,
                    ),
                  if (event.sourceText != null && event.sourceText!.isNotEmpty)
                    _DetailRowData(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '原始输入',
                      value: event.sourceText!,
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingS),
              Center(
                child: TextButton.icon(
                  onPressed: () => _delete(context, ref, event),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('删除提醒'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    textStyle: AppStyles.footnote.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _BottomActions(
          isDone: isDone,
          onComplete: () => _complete(context, ref, event),
          onEdit: () => _edit(context, ref, event),
        ),
      ],
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
  ) async {
    await ref.read(eventListProvider.notifier).completeEvent(event.id);
    await NotificationService().cancelNotification(
      event.id.hashCode & 0x7FFFFFFF,
    );
    ref.invalidate(eventDetailProvider(event.id));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已完成')));
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
  ) async {
    await context.push('/events/${event.id}/edit', extra: event);
    ref.invalidate(eventDetailProvider(event.id));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    HealthEvent event,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除提醒'),
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
    if (ok != true) return;
    await ref.read(eventListProvider.notifier).deleteEvent(event.id);
    await NotificationService().cancelNotification(
      event.id.hashCode & 0x7FFFFFFF,
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  String _timeText(HealthEvent event) {
    final local = event.scheduledAt.toLocal();
    if (event.isAllDay) return DateFormat('yyyy年M月d日').format(local);
    return DateFormat('yyyy年M月d日 HH:mm').format(local);
  }

  String _typeLabel(String type) {
    const labels = {
      'follow_up': '复查',
      'revisit': '复诊',
      'checkup': '体检',
      'medication': '用药',
      'monitoring': '监测',
      'custom': '自定义',
    };
    return labels[type] ?? type;
  }

  IconData _typeIcon(String type) {
    const icons = {
      'follow_up': Icons.search_rounded,
      'revisit': Icons.medical_services_outlined,
      'checkup': Icons.medical_information_outlined,
      'medication': Icons.medication_rounded,
      'monitoring': Icons.monitor_heart_outlined,
      'custom': Icons.more_horiz_rounded,
    };
    return icons[type] ?? Icons.event_note_outlined;
  }

  Color _typeColor(String type) {
    const colors = {
      'follow_up': AppColors.rose,
      'revisit': AppColors.careBlue,
      'medication': AppColors.mintDeep,
      'checkup': AppColors.warmAmber,
      'monitoring': AppColors.lavender,
      'custom': AppColors.textPrimary,
    };
    return colors[type] ?? AppColors.mintDeep;
  }

  String? _repeatLabel(Map<String, dynamic>? repeatRule) {
    final frequency = repeatRule?['frequency'] as String?;
    final interval = (repeatRule?['interval'] as num?)?.toInt() ?? 1;
    if (frequency == null || interval != 1) return null;
    const labels = {'daily': '每天', 'weekly': '每周', 'monthly': '每月'};
    return labels[frequency];
  }

  String _statusLabel(String value) {
    const labels = {
      'pending': '待完成',
      'completed': '已完成',
      'cancelled': '已取消',
    };
    return labels[value] ?? value;
  }

  String _sourceLabel(String value) {
    const labels = {
      'ai_text': 'AI 文本',
      'ai_voice': 'AI 语音',
      'ai_document': 'AI 文档',
      'manual': '手动创建',
    };
    return labels[value] ?? value;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

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
            '提醒详情',
            style: AppStyles.headline.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.event,
    required this.typeLabel,
    required this.typeIcon,
    required this.typeColor,
  });

  final HealthEvent event;
  final String typeLabel;
  final IconData typeIcon;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final isDone = event.status == 'completed';

    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.headline.copyWith(
                          color: isDone
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.spacingS),
                Wrap(
                  spacing: AppStyles.spacingS,
                  runSpacing: AppStyles.spacingS,
                  children: [
                    _Pill(label: typeLabel, color: typeColor),
                    _Pill(
                      label: isDone ? '已完成' : '待完成',
                      color: isDone ? AppColors.success : AppColors.mintDeep,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _DetailRow(data: rows[i], highlighted: i == 0),
            if (i != rows.length - 1)
              const Divider(
                height: AppStyles.dividerThin,
                thickness: AppStyles.dividerThin,
                indent: 56,
                endIndent: AppStyles.cardPadding,
                color: AppColors.lightDivider,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data, this.highlighted = false});

  final _DetailRowData data;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.cardPadding,
        vertical: 13,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: AppColors.mintDeep, size: 20),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: AppStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                Text(
                  data.value,
                  style: (highlighted ? AppStyles.headline : AppStyles.subhead)
                      .copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isDone,
    required this.onComplete,
    required this.onEdit,
  });

  final bool isDone;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

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
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(
            color: AppColors.lightDivider,
            width: AppStyles.dividerThin,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDone) ...[
            Expanded(
              child: _PrimaryActionButton(
                icon: Icons.check_rounded,
                label: '标记完成',
                onTap: onComplete,
              ),
            ),
            const SizedBox(width: AppStyles.spacingS),
          ],
          Expanded(
            child: _SecondaryActionButton(
              icon: Icons.edit_outlined,
              label: '编辑',
              onTap: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppStyles.spacingS),
            Text(
              label,
              style: AppStyles.subhead.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        height: AppStyles.primaryButtonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(color: AppColors.lightOutline),
          boxShadow: AppStyles.subtleShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mintDeep, size: 20),
            const SizedBox(width: AppStyles.spacingS),
            Text(
              label,
              style: AppStyles.subhead.copyWith(
                color: AppColors.mintDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
      ),
      child: Text(
        label,
        style: AppStyles.caption1.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
