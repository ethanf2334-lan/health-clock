import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';
import 'member_avatar.dart';

class CurrentMemberCard extends StatelessWidget {
  const CurrentMemberCard({
    super.key,
    required this.name,
    required this.relationLabel,
    this.age,
    this.pendingCount = 0,
    this.reminderCount = 0,
    this.documentCount = 0,
    this.metricCount = 0,
    required this.relation,
    this.onViewProfile,
    this.onSetCurrent,
    this.isCurrent = true,
  });

  final String name;
  final String relationLabel;
  final int? age;
  final int pendingCount;
  final int reminderCount;
  final int documentCount;
  final int metricCount;
  final String? relation;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSetCurrent;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppStyles.screenMargin,
        AppStyles.spacingXs,
        AppStyles.screenMargin,
        AppStyles.spacingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        child: CustomPaint(
          painter: _CardPatternPainter(),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMain(context),
                const SizedBox(height: AppStyles.spacingM),
                _buildStats(),
                const SizedBox(height: AppStyles.spacingS),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    final ageText = age != null ? '$relationLabel · $age岁' : relationLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MemberAvatar(
          name: name,
          relation: relation,
          size: 64,
          borderColor: Colors.white,
          borderWidth: 2,
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.headline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: AppStyles.spacingS),
                    const _CurrentBadge(),
                  ],
                ],
              ),
              const SizedBox(height: AppStyles.spacingXs),
              Text(
                ageText,
                style: AppStyles.footnote.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildPending(context),
            ],
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        const SizedBox(
          width: 68,
          height: 68,
          child: _FamilyIllustration(),
        ),
      ],
    );
  }

  Widget _buildPending(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
        ),
        children: [
          const TextSpan(text: '近期有 '),
          TextSpan(
            text: '$pendingCount',
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' 条待关注事项'),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      height: AppStyles.compactListRowHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF9),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatPill(
              icon: Icons.notifications_active_rounded,
              iconColor: AppColors.warmAmber,
              label: '提醒',
              value: '$reminderCount',
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatPill(
              icon: Icons.description_rounded,
              iconColor: AppColors.careBlue,
              label: '文档',
              value: '$documentCount',
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatPill(
              icon: Icons.monitor_heart_rounded,
              iconColor: AppColors.mintDeep,
              label: '指标',
              value: '$metricCount',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OutlinedAction(
            icon: Icons.assignment_outlined,
            label: '查看档案',
            onTap: onViewProfile,
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: _FilledAction(
            icon: isCurrent ? Icons.check_circle_rounded : Icons.swap_horiz,
            label: isCurrent ? '当前成员' : '设为当前',
            onTap: isCurrent ? null : onSetCurrent,
          ),
        ),
      ],
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingS,
        vertical: AppStyles.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      ),
      child: Text(
        '当前',
        style: AppStyles.caption1.copyWith(
          color: AppColors.mintDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppStyles.dividerThin,
      height: AppStyles.spacingL,
      color: AppColors.lightOutline,
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppStyles.spacingXs),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: label),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: value,
                    style: AppStyles.headline.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              style: AppStyles.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mint = Paint()
      ..color = AppColors.mintSoft.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final blue = Paint()
      ..color = AppColors.careBlueSoft.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    final coral = Paint()
      ..color = AppColors.coral.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * .84, size.height * .18), 46, mint);
    canvas.drawCircle(Offset(size.width * .96, size.height * .46), 28, blue);
    canvas.drawCircle(Offset(size.width * .70, size.height * .04), 20, coral);

    final line = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.12)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * .58, size.height * .12)
      ..cubicTo(
        size.width * .68,
        size.height * .02,
        size.width * .78,
        size.height * .16,
        size.width * .88,
        size.height * .08,
      );
    canvas.drawPath(path, line);

    final dotPaint = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    for (final point in [
      Offset(size.width * .90, size.height * .20),
      Offset(size.width * .94, size.height * .28),
      Offset(size.width * .86, size.height * .34),
    ]) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Container(
          height: AppStyles.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: AppStyles.spacingXs),
              Text(
                label,
                style: AppStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  const _FilledAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mintDeep,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: SizedBox(
          height: AppStyles.minTouchTarget,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: AppStyles.spacingXs),
              Text(
                label,
                style: AppStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyIllustration extends StatelessWidget {
  const _FamilyIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FamilyIllustrationPainter(),
      size: const Size(80, 80),
    );
  }
}

class _FamilyIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawHouse(canvas, w, h);
    _drawFamily(canvas, w, h);
    _drawHeart(canvas, w, h);
    _drawLeaves(canvas, w, h);
  }

  void _drawHouse(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = w * 0.50;
    final cy = h * 0.42;
    final size = w * 0.46;

    final path = Path();
    path.moveTo(cx - size * 0.55, cy - size * 0.05);
    path.lineTo(cx, cy - size * 0.55);
    path.lineTo(cx + size * 0.55, cy - size * 0.05);
    path.lineTo(cx + size * 0.40, cy - size * 0.05);
    path.lineTo(cx + size * 0.40, cy + size * 0.45);
    path.lineTo(cx - size * 0.40, cy + size * 0.45);
    path.lineTo(cx - size * 0.40, cy - size * 0.05);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawFamily(Canvas canvas, double w, double h) {
    final cx = w * 0.50;
    final cy = h * 0.55;

    final adultPaint = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.7);
    final childPaint = Paint()
      ..color = AppColors.warmAmber.withValues(alpha: 0.85);

    canvas.drawCircle(Offset(cx - w * 0.13, cy), 4, adultPaint);
    canvas.drawCircle(Offset(cx + w * 0.13, cy), 4, adultPaint);
    canvas.drawCircle(Offset(cx, cy + h * 0.05), 3.2, childPaint);

    final bodyPaint = Paint()
      ..color = AppColors.mintDeep.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - w * 0.13, cy + 4),
      Offset(cx - w * 0.13, cy + h * 0.18),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(cx + w * 0.13, cy + 4),
      Offset(cx + w * 0.13, cy + h * 0.18),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(cx, cy + h * 0.08),
      Offset(cx, cy + h * 0.18),
      Paint()
        ..color = AppColors.warmAmber.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHeart(Canvas canvas, double w, double h) {
    final cx = w * 0.78;
    final cy = h * 0.36;
    final s = w * 0.10;

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
  }

  void _drawLeaves(Canvas canvas, double w, double h) {
    final paint = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.45);

    void leaf(double cx, double cy, double size) {
      final path = Path();
      path.moveTo(cx, cy - size);
      path.quadraticBezierTo(cx + size * 0.7, cy, cx, cy + size);
      path.quadraticBezierTo(cx - size * 0.7, cy, cx, cy - size);
      path.close();
      canvas.drawPath(path, paint);
    }

    leaf(w * 0.18, h * 0.18, 5);
    leaf(w * 0.10, h * 0.30, 4);
    leaf(w * 0.92, h * 0.66, 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
