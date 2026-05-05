import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    required this.name,
    required this.phoneDisplay,
    required this.bindingHint,
    this.accountOk = true,
    this.onManageAccountTap,
  });

  final String name;
  final String phoneDisplay;
  final String bindingHint;
  final bool accountOk;
  final VoidCallback? onManageAccountTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.careBlueSoft.withValues(alpha: 0.95),
            AppColors.mintSoft.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onManageAccountTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(name: name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (accountOk) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mintDeep.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppColors.mintDeep,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '账号正常',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mintDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bindingHint,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 72,
              height: 72,
              child: _ShieldArt(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '用' : name.characters.first;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.careBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.mintDeep,
        ),
      ),
    );
  }
}

class _ShieldArt extends StatelessWidget {
  const _ShieldArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShieldPainter(),
      size: const Size(72, 72),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.45;
    final cy = h * 0.48;
    final s = w * 0.32;

    final leaf = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.35);
    void leafAt(double x, double y, double rot) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final p = Path();
      p.moveTo(0, -6);
      p.quadraticBezierTo(8, 0, 0, 6);
      p.quadraticBezierTo(-8, 0, 0, -6);
      canvas.drawPath(p, leaf);
      canvas.restore();
    }

    leafAt(w * 0.88, h * 0.22, 0.6);
    leafAt(w * 0.12, h * 0.78, -0.5);

    final path = Path();
    path.moveTo(cx, cy - s);
    path.quadraticBezierTo(cx + s, cy - s * 0.2, cx + s * 0.95, cy + s * 0.15);
    path.quadraticBezierTo(cx + s * 0.9, cy + s * 0.85, cx, cy + s);
    path.quadraticBezierTo(cx - s * 0.9, cy + s * 0.85, cx - s * 0.95, cy + s * 0.15);
    path.quadraticBezierTo(cx - s, cy - s * 0.2, cx, cy - s);
    path.close();

    canvas.drawShadow(path, AppColors.mintDeep.withValues(alpha: 0.25), 4, false);
    canvas.drawPath(path, Paint()..color = AppColors.mintDeep);

    final tick = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - s * 0.35, cy + s * 0.05), Offset(cx - s * 0.08, cy + s * 0.32), tick);
    canvas.drawLine(Offset(cx - s * 0.08, cy + s * 0.32), Offset(cx + s * 0.42, cy - s * 0.22), tick);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
