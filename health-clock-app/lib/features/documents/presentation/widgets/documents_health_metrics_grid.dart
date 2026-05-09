import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';
import '../../../../shared/models/metric_record.dart';
import '../../../health_records/data/metric_repository.dart';
import '../../../members/providers/current_member_provider.dart';

final documentsHealthMetricsProvider =
    FutureProvider.autoDispose<List<MetricRecord>>((ref) async {
  final memberId = ref.watch(currentMemberIdProvider);
  if (memberId == null || memberId.isEmpty) return const <MetricRecord>[];

  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 7));
  return ref.read(metricRepositoryProvider).listMetrics(
        memberId: memberId,
        startDate: start,
        endDate: end,
      );
});

class DocumentsHealthMetricsGrid extends ConsumerWidget {
  const DocumentsHealthMetricsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ensureCurrentMemberProvider);
    final metricsAsync = ref.watch(documentsHealthMetricsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '健康指标',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/metrics'),
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(10, 6, 2, 6),
                    child: Row(
                      children: [
                        Text(
                          '最近7天',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mintDeep,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.mintDeep,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          metricsAsync.when(
            data: (records) => _MetricsGrid(records: records),
            loading: () => const _MetricsLoadingGrid(),
            error: (_, __) => const _MetricsGrid(records: []),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.records});

  final List<MetricRecord> records;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(records);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 7,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => context.push('/metrics?type=${item.type}'),
          borderRadius: BorderRadius.circular(14),
          child: _MetricCard(data: item),
        );
      },
    );
  }
}

class _MetricsLoadingGrid extends StatelessWidget {
  const _MetricsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 7,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightOutline),
          boxShadow: AppStyles.cardShadow,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Stack(
        children: [
          if (data.trend.length > 1)
            Positioned(
              right: 0,
              bottom: 1,
              child: SizedBox(
                width: 74,
                height: 24,
                child: CustomPaint(
                  painter: _SparklinePainter(data.trend, data.color),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          data.color.withValues(alpha: 0.78),
                          data.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: data.statusBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      data.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: data.color,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      data.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: data.value.length > 8 ? 15 : 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      data.unit,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_MetricCardData> _buildItems(List<MetricRecord> records) {
  final byType = <String, List<MetricRecord>>{};
  for (final record in records) {
    byType.putIfAbsent(record.metricType, () => []).add(record);
  }
  for (final list in byType.values) {
    list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  return [
    _metricData(
      type: 'blood_pressure',
      label: '血压',
      unit: 'mmHg',
      icon: Icons.favorite_rounded,
      color: AppColors.mintDeep,
      statusBg: AppColors.mintBg,
      records: byType['blood_pressure'] ?? const [],
    ),
    _metricData(
      type: 'blood_sugar',
      label: '血糖',
      unit: 'mmol/L',
      icon: Icons.water_drop_rounded,
      color: AppColors.lavender,
      statusBg: AppColors.lavenderSoft,
      records: byType['blood_sugar'] ?? const [],
    ),
    _metricData(
      type: 'weight',
      label: '体重',
      unit: 'kg',
      icon: Icons.monitor_weight_rounded,
      color: const Color(0xFFFF9F16),
      statusBg: AppColors.amberSoft,
      records: byType['weight'] ?? const [],
    ),
    _metricData(
      type: 'heart_rate',
      label: '心率',
      unit: 'bpm',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFFF4E4A),
      statusBg: AppColors.coralSoft,
      records: byType['heart_rate'] ?? const [],
    ),
  ];
}

_MetricCardData _metricData({
  required String type,
  required String label,
  required String unit,
  required IconData icon,
  required Color color,
  required Color statusBg,
  required List<MetricRecord> records,
}) {
  final latest = records.isEmpty ? null : records.first;
  return _MetricCardData(
    type: type,
    label: label,
    value: latest == null ? '--' : _valueText(latest),
    unit: unit,
    time: latest == null ? '暂无记录' : _timeText(latest.recordedAt),
    status: latest == null ? '暂无' : _statusText(latest),
    icon: icon,
    color: color,
    statusBg: statusBg,
    trend: _trend(records),
  );
}

String _valueText(MetricRecord record) {
  if (record.metricType == 'blood_pressure') {
    final diastolic = record.valueExtra?['diastolic'];
    final low = diastolic is num ? diastolic.toDouble() : null;
    if (low != null) return '${_clean(record.value)} / ${_clean(low)}';
  }
  return _clean(record.value);
}

String _statusText(MetricRecord record) {
  switch (record.metricType) {
    case 'blood_pressure':
      final diastolic = record.valueExtra?['diastolic'];
      final low = diastolic is num ? diastolic.toDouble() : null;
      if (record.value >= 90 &&
          record.value < 140 &&
          low != null &&
          low >= 60 &&
          low < 90) {
        return '稳定';
      }
      return '关注';
    case 'blood_sugar':
      return record.value >= 3.9 && record.value <= 7.8 ? '正常' : '关注';
    case 'heart_rate':
      return record.value >= 60 && record.value <= 100 ? '正常' : '关注';
    default:
      return recordsTrendLabel(record.metricType);
  }
}

String recordsTrendLabel(String type) {
  if (type == 'weight') return '已记录';
  return '正常';
}

String _timeText(DateTime time) {
  final now = DateTime.now();
  final local = time.toLocal();
  final sameDay = now.year == local.year &&
      now.month == local.month &&
      now.day == local.day;
  if (sameDay) {
    return '今天 ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
  return '${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
}

List<double> _trend(List<MetricRecord> records) {
  if (records.length < 2) return const [];
  final recent = records.take(9).toList().reversed.toList();
  final values = recent.map((e) => e.value).toList();
  final minValue = values.reduce(math.min);
  final maxValue = values.reduce(math.max);
  if ((maxValue - minValue).abs() < 0.01) {
    return List<double>.filled(values.length, 0.48);
  }
  return values
      .map(
        (value) => 0.82 - ((value - minValue) / (maxValue - minValue)) * 0.64,
      )
      .toList();
}

String _clean(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final shadow = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final line = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = color;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * values[i].clamp(0.08, 0.92);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 1.3, dot);
    }
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _MetricCardData {
  const _MetricCardData({
    required this.type,
    required this.label,
    required this.value,
    required this.unit,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
    required this.statusBg,
    required this.trend,
  });

  final String type;
  final String label;
  final String value;
  final String unit;
  final String time;
  final String status;
  final IconData icon;
  final Color color;
  final Color statusBg;
  final List<double> trend;
}
