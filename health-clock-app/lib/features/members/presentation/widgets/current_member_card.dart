import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
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
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 18),
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
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintDeep.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _buildLabel(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
            child: _buildMain(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _buildStats(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.mintDeep,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          '当前成员',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.mintDeep,
          ),
        ),
      ],
    );
  }

  Widget _buildMain(BuildContext context) {
    final ageText = age != null ? '$relationLabel · $age岁' : relationLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MemberAvatarWithBadge(
          name: name,
          relation: relation,
          badgeText: '当前成员',
          size: 78,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ageText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPending(context),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 80,
          height: 80,
          child: _FamilyIllustration(),
        ),
      ],
    );
  }

  Widget _buildPending(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12.5,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
        children: [
          const TextSpan(text: '近期有 '),
          TextSpan(
            text: '$pendingCount',
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: ' 条待关注事项'),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: _StatPill(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.warmAmber,
            label: '提醒',
            value: '$reminderCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            icon: Icons.description_rounded,
            iconColor: AppColors.careBlue,
            label: '文档',
            value: '$documentCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            icon: Icons.monitor_heart_rounded,
            iconColor: AppColors.mintDeep,
            label: '指标',
            value: '$metricCount',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: _OutlinedAction(
            icon: Icons.assignment_outlined,
            label: '查看档案',
            onTap: onViewProfile,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilledAction(
            icon: isCurrent ? Icons.check_circle_rounded : Icons.swap_horiz,
            label: isCurrent ? '当前成员' : '设为当前',
            onTap: isCurrent ? null : onSetCurrent,
          ),
        ),
        const SizedBox(width: 4),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
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

    final adultPaint = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.7);
    final childPaint = Paint()..color = AppColors.warmAmber.withValues(alpha: 0.85);

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
