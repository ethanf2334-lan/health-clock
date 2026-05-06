import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DocumentsHealthMetricsGrid extends StatelessWidget {
  const DocumentsHealthMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _MetricCardData(
        label: '血压',
        value: '128/82',
        unit: 'mmHg',
        time: '今天 08:30',
        status: '较稳定',
        icon: Icons.favorite_rounded,
        color: AppColors.mintDeep,
        statusBg: AppColors.mintBg,
        trend: [0.42, 0.38, 0.52, 0.35, 0.58, 0.50, 0.70, 0.44, 0.66],
      ),
      _MetricCardData(
        label: '血糖',
        value: '5.8',
        unit: 'mmol/L',
        time: '昨天',
        status: '空腹',
        icon: Icons.water_drop_rounded,
        color: AppColors.lavender,
        statusBg: AppColors.lavenderSoft,
        trend: [0.50, 0.54, 0.36, 0.49, 0.28, 0.46, 0.31, 0.58, 0.34],
      ),
      _MetricCardData(
        label: '体重',
        value: '58.4',
        unit: 'kg',
        time: '07/08',
        status: '本周 -0.6',
        icon: Icons.monitor_weight_rounded,
        color: Color(0xFFFF9F16),
        statusBg: AppColors.amberSoft,
        trend: [0.52, 0.30, 0.49, 0.26, 0.48, 0.22, 0.41, 0.50, 0.29],
      ),
      _MetricCardData(
        label: '心率',
        value: '76',
        unit: 'bpm',
        time: '今天',
        status: '正常',
        icon: Icons.favorite_rounded,
        color: Color(0xFFFF4E4A),
        statusBg: AppColors.coralSoft,
        trend: [0.55, 0.31, 0.45, 0.58, 0.40, 0.67, 0.36, 0.62, 0.29],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 0, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '健康指标',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '最近7天',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          GridView.builder(
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
            itemBuilder: (context, index) => _MetricCard(data: items[index]),
          ),
        ],
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
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
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
                        fontWeight: FontWeight.w800,
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
                        fontWeight: FontWeight.w800,
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
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: 0,
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
