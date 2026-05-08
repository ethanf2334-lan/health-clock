import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';

/// 顶部"今天状态"卡片：状态摘要 + 日历时钟插画。
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
      margin: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        0,
        AppStyles.screenMargin,
        AppStyles.spacingM,
      ),
      height: 148,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3FFFA),
            Color(0xFFE5F8F1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        border: Border.all(
          color: AppColors.mintSoft.withValues(alpha: 0.78),
          width: AppStyles.borderRegular,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintDeep.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _StatusCardBackgroundPainter()),
          ),
          Positioned(
            right: -2,
            top: -2,
            bottom: -4,
            child: SizedBox(
              width: 190,
              child: _StatusIllustration(
                hasAttention: overdueCount > 0 || medicationCount > 0,
              ),
            ),
          ),
          Positioned(
            left: AppStyles.cardPadding,
            top: AppStyles.cardPadding,
            bottom: AppStyles.cardPadding,
            right: 156,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.title2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintDeep,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingS),
                _buildSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '今天状态',
          style: AppStyles.subhead.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppStyles.spacingXs),
        const Icon(
          Icons.auto_awesome_rounded,
          size: 17,
          color: AppColors.mintDeep,
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.auto_awesome_rounded,
          size: 11,
          color: AppColors.mintDeep.withValues(alpha: 0.72),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final parts = <InlineSpan>[];
    void addCount(int count, String label, Color color) {
      if (count <= 0) return;
      if (parts.isNotEmpty) {
        parts.add(
          TextSpan(
            text: ' · ',
            style: AppStyles.subhead.copyWith(color: AppColors.textSecondary),
          ),
        );
      }
      parts
        ..add(
          TextSpan(
            text: '$count',
            style: AppStyles.subhead.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
        ..add(
          TextSpan(
            text: ' 个$label',
            style: AppStyles.subhead.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }

    addCount(followUpCount, '复查提醒', AppColors.mintDeep);
    addCount(medicationCount, '用药提醒', AppColors.coral);
    addCount(checkupCount, '体检提醒', AppColors.careBlue);
    addCount(overdueCount, '逾期事项', AppColors.danger);

    if (parts.isEmpty) {
      return Text(
        summary,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: parts),
    );
  }
}

class _StatusCardBackgroundPainter extends CustomPainter {
  const _StatusCardBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(w * 0.58, h * 0.36),
          radius: w * 0.36,
        ),
      );
    canvas.drawCircle(Offset(w * 0.58, h * 0.36), w * 0.36, glow);

    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.64);
    void cloud(double x, double y, double scale, double alpha) {
      final p = Paint()..color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y + 8 * scale), 18 * scale, p);
      canvas.drawCircle(Offset(x + 20 * scale, y), 25 * scale, p);
      canvas.drawCircle(Offset(x + 48 * scale, y + 9 * scale), 20 * scale, p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 6 * scale, y + 10 * scale, 70 * scale, 22 * scale),
          Radius.circular(18 * scale),
        ),
        p,
      );
    }

    cloud(w * 0.43, h * 0.24, 0.86, 0.55);
    cloud(w * 0.71, h * 0.18, 0.92, 0.76);
    cloud(w * 0.84, h * 0.31, 0.58, 0.48);

    final mist = Paint()
      ..color = AppColors.mintSoft.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.70, h * 0.78),
        width: w * 0.62,
        height: h * 0.34,
      ),
      mist,
    );

    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          AppColors.mintSoft.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), wash);

    canvas.drawCircle(Offset(w * 0.90, h * 0.12), 3.5, cloudPaint);
    canvas.drawCircle(Offset(w * 0.93, h * 0.12), 3.5, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 装饰插画：日历 + 时钟 + 心 + 叶
class _StatusIllustration extends StatelessWidget {
  const _StatusIllustration({required this.hasAttention});

  final bool hasAttention;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IllustrationPainter(hasAttention: hasAttention),
      size: const Size(190, 150),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter({required this.hasAttention});

  final bool hasAttention;

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
    final cw = w * 0.43;
    final ch = h * 0.66;
    final left = w * 0.45;
    final top = h * 0.12;
    final rect = Rect.fromLTWH(left, top, cw, ch);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    final shadow = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawRRect(rrect.shift(const Offset(0, 6)), shadow);

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
    final headerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF82D0A5), Color(0xFF57B77E)],
      ).createShader(headerRect);
    canvas.drawPath(headerPath, headerPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF7F9188)
      ..style = PaintingStyle.fill;
    final ringStroke = Paint()
      ..color = const Color(0xFF7F9188)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final ringTopY = top - 7;
    for (final x in [left + cw * 0.28, left + cw * 0.72]) {
      canvas.drawLine(Offset(x, ringTopY), Offset(x, top + 10), ringStroke);
      canvas.drawCircle(Offset(x, ringTopY), 3.3, ringPaint);
    }

    final checkBg = Paint()..color = const Color(0xFFE9F7EF);
    final checkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + cw * 0.36, top + ch * 0.42, cw * 0.42, ch * 0.31),
      const Radius.circular(8),
    );
    canvas.drawRRect(checkRect, checkBg);

    final tickPaint = Paint()
      ..color = const Color(0xFF65BE8E)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final cx = left + cw * 0.57;
    final cy = top + ch * 0.57;
    canvas.drawLine(
      Offset(cx - 9, cy),
      Offset(cx - 2, cy + 7),
      tickPaint,
    );
    canvas.drawLine(
      Offset(cx - 2, cy + 7),
      Offset(cx + 12, cy - 9),
      tickPaint,
    );
  }

  void _drawClock(Canvas canvas, double w, double h) {
    final cx = w * 0.39;
    final cy = h * 0.73;
    final r = w * 0.17;

    final shadow = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(Offset(cx, cy + 4), r + 2, shadow);

    final body = Paint()..color = AppColors.mintDeep;
    canvas.drawCircle(Offset(cx, cy), r, body);

    final inner = Paint()..color = const Color(0xFFE6F8EF);
    canvas.drawCircle(Offset(cx, cy), r - 4, inner);

    final hand = Paint()
      ..color = AppColors.mintDeep
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - r * 0.55), hand);
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.36, cy + r * 0.20), hand);

    final centerDot = Paint()..color = AppColors.mintDeep;
    canvas.drawCircle(Offset(cx, cy), 2, centerDot);
  }

  void _drawHeart(Canvas canvas, double w, double h) {
    final cx = w * 0.84;
    final cy = h * 0.78;
    final s = w * 0.10;

    final bgCircle = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);
    canvas.drawCircle(Offset(cx, cy), s + 4, bgCircle);

    final heartPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF9B8F), Color(0xFFFF6E79)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: s * 1.4));

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
    final leafPaint = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.32);

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

    leaf(w * 0.90, h * 0.34, 13, math.pi / 5);
    leaf(w * 0.98, h * 0.44, 10, math.pi / 2.4);
    leaf(w * 0.92, h * 0.56, 7, math.pi / 3.2);
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.hasAttention != hasAttention;
}
