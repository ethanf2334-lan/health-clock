import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../shared/models/metric_record.dart';
import '../../home/presentation/widgets/metric_record_sheet.dart';
import '../../members/presentation/member_labels.dart';
import '../../members/presentation/widgets/member_avatar.dart';
import '../../members/providers/current_member_provider.dart';
import '../../members/providers/member_provider.dart';
import '../providers/metric_provider.dart';

const _defaultMetricType = 'blood_pressure';

const _metricTypes = [
  _MetricType(
    'blood_pressure',
    '血压',
    Icons.monitor_heart_rounded,
    AppColors.mintDeep,
  ),
  _MetricType(
    'blood_sugar',
    '血糖',
    Icons.water_drop_rounded,
    AppColors.lavender,
  ),
  _MetricType('weight', '体重', Icons.scale_rounded, Color(0xFF7384E8)),
  _MetricType('heart_rate', '心率', Icons.favorite_rounded, AppColors.rose),
  _MetricType(
    'temperature',
    '体温',
    Icons.thermostat_rounded,
    AppColors.careBlue,
  ),
  _MetricType(
    'blood_oxygen',
    '血氧',
    Icons.water_drop_outlined,
    Color(0xFF7EC7F2),
  ),
];

class MetricHistoryScreen extends ConsumerStatefulWidget {
  const MetricHistoryScreen({super.key, this.initialType});

  final String? initialType;

  @override
  ConsumerState<MetricHistoryScreen> createState() =>
      _MetricHistoryScreenState();
}

class _MetricHistoryScreenState extends ConsumerState<MetricHistoryScreen> {
  String? _type;

  @override
  void initState() {
    super.initState();
    _type = _isKnownType(widget.initialType)
        ? widget.initialType
        : _defaultMetricType;
    WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
  }

  @override
  void didUpdateWidget(covariant MetricHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialType != widget.initialType) {
      final next = _isKnownType(widget.initialType)
          ? widget.initialType
          : _defaultMetricType;
      if (next != _type) {
        setState(() => _type = next);
        WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
      }
    }
  }

  bool _isKnownType(String? type) =>
      type != null && _metricTypes.any((item) => item.value == type);

  void _apply() {
    ref.read(metricListProvider.notifier).setFilter(
          MetricFilter(
            memberId: ref.read(currentMemberIdProvider),
            metricType: _type,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    ref.listen(currentMemberIdProvider, (_, __) => _apply());
    final async = ref.watch(metricListProvider);
    final membersAsync = ref.watch(memberListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(metricListProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              AppStyles.screenMargin,
              AppStyles.spacingS,
              AppStyles.screenMargin,
              AppStyles.spacingL + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              _Header(
                membersAsync: membersAsync,
                onMemberTap: _showMemberPicker,
              ),
              const SizedBox(height: AppStyles.spacingM),
              _MetricTypeBar(
                selectedType: _type,
                onSelected: (value) {
                  setState(() => _type = value);
                  _apply();
                },
              ),
              const SizedBox(height: AppStyles.spacingM),
              async.when(
                data: _buildLoaded,
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppStyles.spacingXxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _EmptyState(text: '加载失败：$e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(List<MetricRecord> source) {
    final records = [...source]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final selected = _selectedMetric(records);
    final recent = records.take(3).toList();
    final trendRecords = selected == null
        ? const <MetricRecord>[]
        : records
            .where((item) => item.metricType == selected.metricType)
            .take(7)
            .toList();

    return Column(
      children: [
        if (selected == null)
          const _EmptyState(text: '暂无指标记录')
        else ...[
          _StatusCard(record: selected),
          const SizedBox(height: AppStyles.spacingM),
          _TrendCard(record: selected, records: trendRecords),
          const SizedBox(height: AppStyles.spacingM),
          _RecentRecordsCard(records: recent, onAdd: _openRecordSheet),
          const SizedBox(height: AppStyles.spacingM),
          const _AdviceCard(),
        ],
      ],
    );
  }

  MetricRecord? _selectedMetric(List<MetricRecord> records) {
    if (records.isEmpty) return null;
    for (final record in records) {
      if (record.metricType == _type) return record;
    }
    return records.first;
  }

  void _openRecordSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppStyles.radiusXl),
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.73,
              child: MetricRecordSheet(
                onSaved: () => ref.read(metricListProvider.notifier).refresh(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMemberPicker() {
    final membersAsync = ref.read(memberListProvider);
    final currentId = ref.read(currentMemberIdProvider);
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
                padding: const EdgeInsets.all(AppStyles.spacingM),
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
                  subtitle: Text(memberRelationLabel(member.relation)),
                  trailing: currentId == member.id
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mintDeep,
                        )
                      : null,
                  onTap: () {
                    ref.read(currentMemberIdProvider.notifier).state =
                        member.id;
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
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.membersAsync,
    required this.onMemberTap,
  });

  final AsyncValue membersAsync;
  final VoidCallback onMemberTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentId = ref.watch(currentMemberIdProvider);
    final member = membersAsync.maybeWhen(
      data: (members) {
        for (final item in members) {
          if (item.id == currentId) return item;
        }
        return members.isEmpty ? null : members.first;
      },
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (context.canPop()) ...[
              _BackButton(onTap: () => context.pop()),
              const SizedBox(width: AppStyles.spacingS),
            ],
            Expanded(
              child: Text(
                '健康指标',
                style: AppStyles.screenTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                member == null ? '记录和查看健康变化' : '为${member.name}记录和查看健康变化',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.footnote.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppStyles.spacingS),
            _MemberPill(
              name: member?.name,
              relation: member?.relation,
              onTap: onMemberTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppStyles.minTouchTarget,
          height: AppStyles.minTouchTarget,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: AppStyles.subtleShadow,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  const _MemberPill({
    required this.name,
    required this.relation,
    required this.onTap,
  });

  final String? name;
  final String? relation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
        child: Container(
          height: AppStyles.minTouchTarget,
          padding: const EdgeInsets.only(
            left: AppStyles.spacingS,
            right: AppStyles.spacingXxs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            border: Border.all(color: AppColors.lightOutline),
            boxShadow: AppStyles.subtleShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MemberAvatar(name: name, relation: relation, size: 28),
              const SizedBox(width: AppStyles.spacingS),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 56),
                child: Text(
                  name ?? '请选择',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
    );
  }
}

class _MetricTypeBar extends StatelessWidget {
  const _MetricTypeBar({
    required this.selectedType,
    required this.onSelected,
  });

  final String? selectedType;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppStyles.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _metricTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppStyles.spacingS),
        itemBuilder: (context, index) {
          final item = _metricTypes[index];
          final selected = item.value == selectedType;
          return InkWell(
            onTap: () => onSelected(item.value),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.spacingS,
              ),
              decoration: BoxDecoration(
                color: selected ? item.color : Colors.white,
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                border: Border.all(
                  color: selected ? item.color : AppColors.lightOutline,
                ),
                boxShadow: AppStyles.subtleShadow,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: selected ? Colors.white : AppColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                  Text(
                    item.label,
                    style: AppStyles.footnote.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.record});

  final MetricRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(record.metricType);
    final latestTime = _friendlyTime(record.recordedAt);
    final status = _statusText(record);

    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.mintBgLight.withValues(alpha: 0.76),
            Colors.white,
          ],
          stops: const [0, 0.42, 1],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _typeIcon(record.metricType),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: Text(
                  '今日状态',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              _StatusPill(text: status, color: color),
            ],
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            '最新${_typeLabel(record.metricType)}',
            style: AppStyles.footnote.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _displayValue(record),
                    style: AppStyles.title1.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' ${record.unit}',
                    style: AppStyles.footnote.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            '更新时间：$latestTime',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.footnote.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppStyles.spacingS),
          const _StatusHintStrip(),
        ],
      ),
    );
  }
}

class _StatusHintStrip extends StatelessWidget {
  const _StatusHintStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.mintBgLight.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco_rounded,
            color: AppColors.mintDeep,
            size: 14,
          ),
          const SizedBox(width: AppStyles.spacingS),
          Expanded(
            child: Text(
              '整体稳定，继续保持规律记录',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

  final String text;
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
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      ),
      child: Text(
        text,
        style: AppStyles.caption1.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.record, required this.records});

  final MetricRecord record;
  final List<MetricRecord> records;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(record.metricType);
    final summary = _trendSummary(records);

    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.mintBgLight.withValues(alpha: 0.64),
            Colors.white,
          ],
          stops: const [0, 0.50, 1],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '趋势变化',
                      style: AppStyles.subhead.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spacingXxs),
                    Text(
                      summary,
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
              _TrendLegend(color: color),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          SizedBox(
            height: 188,
            child: _TrendChart(records: records, color: color),
          ),
        ],
      ),
    );
  }

  String _trendSummary(List<MetricRecord> source) {
    if (source.length < 2) return '记录更多后可查看趋势';
    final ordered = [...source]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final start = ordered.first;
    final end = ordered.last;
    return '${_friendlyTime(start.recordedAt)} 至 ${_friendlyTime(end.recordedAt)}';
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: color, label: '收缩压'),
        const SizedBox(width: AppStyles.spacingS),
        const _LegendItem(color: AppColors.careBlue, label: '舒张压'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppStyles.spacingS,
          height: AppStyles.spacingXxs,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppStyles.radiusFull),
          ),
        ),
        const SizedBox(width: AppStyles.spacingXs),
        Text(
          label,
          style: AppStyles.caption1.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.records, required this.color});

  final List<MetricRecord> records;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final sorted = [...records]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    if (sorted.length < 2) {
      return Center(
        child: Text(
          '记录更多后生成趋势',
          style: AppStyles.caption1.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    final systolic = <FlSpot>[];
    final diastolic = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      final record = sorted[i];
      systolic.add(FlSpot(i.toDouble(), record.value));
      final d = record.valueExtra?['diastolic'];
      if (d is num) diastolic.add(FlSpot(i.toDouble(), d.toDouble()));
    }
    final maxY = _maxY(sorted);
    final interval = maxY / 5;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.lightDivider.withValues(alpha: 0.7),
            strokeWidth: AppStyles.dividerThin,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'mmHg',
                style: AppStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            axisNameSize: 18,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.round().toString(),
                  style: AppStyles.caption1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return _BottomChartTitle(value: value, records: sorted);
              },
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: systolic,
            isCurved: true,
            barWidth: 3,
            color: color,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
          if (diastolic.length == systolic.length)
            LineChartBarData(
              spots: diastolic,
              isCurved: true,
              barWidth: 3,
              color: AppColors.careBlue,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.careBlue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _maxY(List<MetricRecord> records) {
    final values = <double>[
      for (final record in records) record.value,
      for (final record in records)
        if (record.valueExtra?['diastolic'] is num)
          (record.valueExtra!['diastolic'] as num).toDouble(),
    ];
    if (values.isEmpty) return 1;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 150) return 150;
    return ((max + 40) / 50).ceil() * 50;
  }
}

class _BottomChartTitle extends StatelessWidget {
  const _BottomChartTitle({required this.value, required this.records});

  final double value;
  final List<MetricRecord> records;

  @override
  Widget build(BuildContext context) {
    final index = value.round();
    if (index < 0 || index >= records.length) return const SizedBox.shrink();
    final lastIndex = records.length - 1;
    final middleIndex = lastIndex ~/ 2;
    if (index != 0 && index != middleIndex && index != lastIndex) {
      return const SizedBox.shrink();
    }

    final label = index == lastIndex
        ? '今天 ${DateFormat('HH:mm').format(records[index].recordedAt)}'
        : DateFormat('M/d HH:mm').format(records[index].recordedAt);
    final alignment = index == 0
        ? Alignment.centerLeft
        : index == lastIndex
            ? Alignment.centerRight
            : Alignment.center;

    return Align(
      alignment: alignment,
      child: Text(
        label,
        style: AppStyles.caption1.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RecentRecordsCard extends StatelessWidget {
  const _RecentRecordsCard({required this.records, required this.onAdd});

  final List<MetricRecord> records;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.mintDeep,
              size: 22,
            ),
            const SizedBox(width: AppStyles.spacingS),
            Expanded(
              child: Text(
                '近期记录',
                style: AppStyles.subhead.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _AddMetricButton(onTap: onAdd),
          ],
        ),
        const SizedBox(height: AppStyles.spacingS),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            border: Border.all(color: AppColors.lightOutline),
            boxShadow: AppStyles.cardShadow,
          ),
          child: Column(
            children: records.isEmpty
                ? const [_RecentEmptyRow()]
                : [
                    for (var i = 0; i < records.length; i++) ...[
                      _MetricRow(record: records[i]),
                      if (i != records.length - 1)
                        const Divider(
                          height: AppStyles.dividerThin,
                          color: AppColors.lightDivider,
                        ),
                    ],
                  ],
          ),
        ),
      ],
    );
  }
}

class _AddMetricButton extends StatelessWidget {
  const _AddMetricButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mintBg.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacingS,
            vertical: AppStyles.spacingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                color: AppColors.mintDeep,
                size: 18,
              ),
              const SizedBox(width: AppStyles.spacingXs),
              Text(
                '记录',
                style: AppStyles.caption1.copyWith(
                  color: AppColors.mintDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEmptyRow extends StatelessWidget {
  const _RecentEmptyRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      child: Text(
        '还没有近期记录',
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.record});

  final MetricRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(record.metricType);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingM,
        vertical: AppStyles.spacingS,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              _friendlyTime(record.recordedAt),
              style: AppStyles.subhead.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _displayValue(record),
                    style: AppStyles.title3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' ${record.unit}',
                    style: AppStyles.caption1.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (record.metricType == 'blood_pressure' &&
              record.valueExtra?['heart_rate'] != null) ...[
            const SizedBox(width: AppStyles.spacingS),
            const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.rose,
              size: 18,
            ),
            const SizedBox(width: AppStyles.spacingXs),
            Text(
              '心率 ${_cleanNum(record.valueExtra!['heart_rate'])}',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(width: AppStyles.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyles.spacingS,
              vertical: AppStyles.spacingXs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppStyles.radiusFull),
            ),
            child: Text(
              _statusText(record),
              style: AppStyles.caption1.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.mintBg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.mintDeep, size: 34),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '建议继续保持规律测量',
                  style: AppStyles.subhead.copyWith(
                    color: AppColors.mintDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                Text(
                  '坚持记录有助于更好地了解健康变化，及时发现异常。',
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.monitor_heart_outlined,
            color: AppColors.textTertiary,
            size: 40,
          ),
          const SizedBox(height: AppStyles.spacingS),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppStyles.subhead.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricType {
  const _MetricType(this.value, this.label, this.icon, this.color);

  final String? value;
  final String label;
  final IconData icon;
  final Color color;
}

String _displayValue(MetricRecord record) {
  if (record.metricType == 'blood_pressure' && record.valueExtra != null) {
    final diastolic = record.valueExtra!['diastolic'];
    if (diastolic != null) {
      return '${_cleanNum(record.value)} / ${_cleanNum(diastolic)}';
    }
  }
  return _cleanNum(record.value);
}

String _cleanNum(Object value) {
  final number = value is num ? value.toDouble() : double.tryParse('$value');
  if (number == null) return '$value';
  if (number % 1 == 0) return number.toInt().toString();
  return number.toStringAsFixed(1);
}

String _friendlyTime(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final day = DateTime(time.year, time.month, time.day);
  final clock = DateFormat('HH:mm').format(time);
  if (day == today) return '今天 $clock';
  if (day == yesterday) return '昨天 $clock';
  return DateFormat('M月d日 HH:mm').format(time);
}

String _typeLabel(String t) {
  for (final item in _metricTypes) {
    if (item.value == t) return item.label;
  }
  return t;
}

IconData _typeIcon(String t) {
  for (final item in _metricTypes) {
    if (item.value == t) return item.icon;
  }
  return Icons.show_chart_rounded;
}

Color _colorFor(String t) {
  for (final item in _metricTypes) {
    if (item.value == t) return item.color;
  }
  return AppColors.mintDeep;
}

String _statusText(MetricRecord record) {
  switch (record.metricType) {
    case 'blood_pressure':
      return record.value >= 140 ? '偏高' : '正常';
    case 'blood_sugar':
      return record.value >= 7 ? '关注' : '正常';
    case 'heart_rate':
      return record.value < 60 || record.value > 100 ? '关注' : '正常';
    case 'temperature':
      return record.value >= 37.3 ? '发热' : '正常';
    case 'blood_oxygen':
      return record.value < 95 ? '偏低' : '正常';
    default:
      return '已记录';
  }
}
