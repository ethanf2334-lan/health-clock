import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 顶部"今天状态"卡片：渐变薄荷绿背景 + 右侧装饰插画
class TodayStatusCard extends StatelessWidget {
  const TodayStatusCard({
    super.key,
    required this.title,
    required this.summary,
    required this.followUpCount,
    required this.medicationCount,
    required this.checkupCount,
    this.overdueCount = 0,
  });

  final String title;
  final String summary;
  final int followUpCount;
  final int medicationCount;
  final int checkupCount;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.statusGradientStart,
            AppColors.statusGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.mintSoft.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintDeep.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                _buildLabel(),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 110,
            height: 110,
            child: _StatusIllustration(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '今天状态',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mintDeep,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(width: 4),
          Text(
            '✨',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 装饰插画：日历 + 时钟 + 心 + 叶
class _StatusIllustration extends StatelessWidget {
  const _StatusIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IllustrationPainter(),
      size: const Size(110, 110),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawLeaves(canvas, w, h);
    _drawCalendar(canvas, w, h);
    _drawClock(canvas, w, h);
    _drawHeart(canvas, w, h);
  }

  void _drawCalendar(Canvas canvas, double w, double h) {
    final cw = w * 0.62;
    final ch = h * 0.66;
    final left = w * 0.18;
    final top = h * 0.22;
    final rect = Rect.fromLTWH(left, top, cw, ch);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(rrect.shift(const Offset(0, 2)), shadow);

    final body = Paint()..color = Colors.white;
    canvas.drawRRect(rrect, body);

    final headerHeight = ch * 0.30;
    final headerRect = Rect.fromLTWH(left, top, cw, headerHeight);
    final headerPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          headerRect,
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
      );
    final headerPaint = Paint()..color = AppColors.mintSoft;
    canvas.drawPath(headerPath, headerPaint);

    final ringPaint = Paint()
      ..color = AppColors.mintDeep
      ..style = PaintingStyle.fill;
    final ringTopY = top - 4;
    canvas.drawCircle(Offset(left + cw * 0.30, ringTopY), 3.5, ringPaint);
    canvas.drawCircle(Offset(left + cw * 0.70, ringTopY), 3.5, ringPaint);

    final tickPaint = Paint()
      ..color = AppColors.mintDeep
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final cx = left + cw * 0.50;
    final cy = top + headerHeight + (ch - headerHeight) * 0.55;
    canvas.drawLine(
      Offset(cx - 8, cy),
      Offset(cx - 1, cy + 6),
      tickPaint,
    );
    canvas.drawLine(
      Offset(cx - 1, cy + 6),
      Offset(cx + 9, cy - 6),
      tickPaint,
    );
  }

  void _drawClock(Canvas canvas, double w, double h) {
    final cx = w * 0.30;
    final cy = h * 0.62;
    final r = w * 0.22;

    final shadow = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx, cy + 2), r + 1, shadow);

    final body = Paint()..color = AppColors.mintDeep;
    canvas.drawCircle(Offset(cx, cy), r, body);

    final inner = Paint()..color = AppColors.mintSoft;
    canvas.drawCircle(Offset(cx, cy), r - 3, inner);

    final hand = Paint()
      ..color = AppColors.mintDeep
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - r * 0.55), hand);
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.45, cy), hand);

    final centerDot = Paint()..color = AppColors.mintDeep;
    canvas.drawCircle(Offset(cx, cy), 2, centerDot);
  }

  void _drawHeart(Canvas canvas, double w, double h) {
    final cx = w * 0.78;
    final cy = h * 0.72;
    final s = w * 0.13;

    final bgCircle = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), s + 4, bgCircle);

    final heartPaint = Paint()..color = AppColors.coral;

    final path = Path();
    path.moveTo(cx, cy + s * 0.65);
    path.cubicTo(
      cx - s * 1.15,
      cy - s * 0.05,
      cx - s * 0.55,
      cy - s * 0.95,
      cx,
      cy - s * 0.18,
    );
    path.cubicTo(
      cx + s * 0.55,
      cy - s * 0.95,
      cx + s * 1.15,
      cy - s * 0.05,
      cx,
      cy + s * 0.65,
    );
    path.close();
    canvas.drawPath(path, heartPaint);

    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy - s * 0.30),
      Offset(cx, cy + s * 0.20),
      cross,
    );
    canvas.drawLine(
      Offset(cx - s * 0.25, cy - s * 0.05),
      Offset(cx + s * 0.25, cy - s * 0.05),
      cross,
    );
  }

  void _drawLeaves(Canvas canvas, double w, double h) {
    final leafPaint = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.55);

    void leaf(double cx, double cy, double size, double rotation) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      final path = Path();
      path.moveTo(0, -size);
      path.quadraticBezierTo(size * 0.7, -size * 0.2, 0, size);
      path.quadraticBezierTo(-size * 0.7, -size * 0.2, 0, -size);
      path.close();
      canvas.drawPath(path, leafPaint);

      final vein = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, -size), Offset(0, size), vein);
      canvas.restore();
    }

    leaf(w * 0.85, h * 0.20, 9, math.pi / 5);
    leaf(w * 0.92, h * 0.30, 7, math.pi / 2.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
