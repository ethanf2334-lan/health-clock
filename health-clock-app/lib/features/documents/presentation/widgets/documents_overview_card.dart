import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class DocumentsOverviewCard extends StatelessWidget {
  const DocumentsOverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.newCount,
    required this.pendingReview,
    required this.candidateReminders,
  });

  final String title;
  final String subtitle;
  final int newCount;
  final int pendingReview;
  final int candidateReminders;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintDeep,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: _DocsIllustration(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.description_rounded,
                    iconColor: AppColors.mintDeep,
                    iconBg: AppColors.mintSoft,
                    label: '本月新增',
                    value: newCount,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.find_in_page_rounded,
                    iconColor: AppColors.careBlue,
                    iconBg: AppColors.careBlueSoft,
                    label: '待审核',
                    value: pendingReview,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppColors.warmAmber,
                    iconBg: AppColors.amberSoft,
                    label: '可生成提醒',
                    value: candidateReminders,
                  ),
                ),
              ],
            ),
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
      child: const Text(
        '档案概览',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.mintDeep,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.0,
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

class _DocsIllustration extends StatelessWidget {
  const _DocsIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DocsIllustrationPainter(),
      size: const Size(100, 100),
    );
  }
}

class _DocsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawLeaves(canvas, w, h);
    _drawFolderStack(canvas, w, h);
    _drawShield(canvas, w, h);
  }

  void _drawFolderStack(Canvas canvas, double w, double h) {
    // 后层文档纸（白色带阴影）
    final paperShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final back = Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.50, h * 0.55);
    final backRrect = RRect.fromRectAndRadius(back, const Radius.circular(8));
    canvas.drawRRect(backRrect.shift(const Offset(0, 2)), paperShadow);
    canvas.drawRRect(backRrect, Paint()..color = Colors.white);

    // 后纸条纹
    final lineLight = Paint()
      ..color = AppColors.mintSoft.withValues(alpha: 0.7)
      ..strokeWidth = 1.6;
    for (int i = 0; i < 4; i++) {
      final y = back.top + 14 + i * 7;
      canvas.drawLine(
        Offset(back.left + 8, y),
        Offset(back.right - 8, y),
        lineLight,
      );
    }

    // 前层文件夹（绿色）
    final folderBg = Paint()..color = AppColors.mintDeep;
    final folder = Rect.fromLTWH(w * 0.15, h * 0.32, w * 0.55, h * 0.50);
    final folderRrect =
        RRect.fromRectAndRadius(folder, const Radius.circular(10));

    canvas.drawRRect(
      folderRrect.shift(const Offset(0, 2)),
      Paint()
        ..color = AppColors.mintDeep.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(folderRrect, folderBg);

    // 文件夹标签突起
    final tab = Rect.fromLTWH(folder.left + 8, folder.top - 6, 22, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tab, const Radius.circular(4)),
      folderBg,
    );

    // 文件夹中央白色区域
    final centerRect = Rect.fromLTWH(
      folder.left + 8,
      folder.top + 8,
      folder.width - 16,
      folder.height - 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );

    // 红十字药品标志
    final crossPaint = Paint()..color = AppColors.coral;
    final cx = centerRect.center.dx;
    final cy = centerRect.center.dy;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 4, height: 18),
        const Radius.circular(2),
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 4),
        const Radius.circular(2),
      ),
      crossPaint,
    );
  }

  void _drawShield(Canvas canvas, double w, double h) {
    final cx = w * 0.85;
    final cy = h * 0.62;
    final s = w * 0.10;

    final path = Path();
    path.moveTo(cx, cy - s);
    path.quadraticBezierTo(cx + s, cy - s, cx + s, cy);
    path.quadraticBezierTo(cx + s, cy + s * 0.7, cx, cy + s);
    path.quadraticBezierTo(cx - s, cy + s * 0.7, cx - s, cy);
    path.quadraticBezierTo(cx - s, cy - s, cx, cy - s);
    path.close();

    final shield = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.85);
    canvas.drawPath(path, shield);

    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - s * 0.40, cy + s * 0.05),
      Offset(cx - s * 0.10, cy + s * 0.35),
      tickPaint,
    );
    canvas.drawLine(
      Offset(cx - s * 0.10, cy + s * 0.35),
      Offset(cx + s * 0.50, cy - s * 0.30),
      tickPaint,
    );
  }

  void _drawLeaves(Canvas canvas, double w, double h) {
    final paint = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.45);

    void leaf(double cx, double cy, double size, double rotation) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      final path = Path();
      path.moveTo(0, -size);
      path.quadraticBezierTo(size * 0.7, 0, 0, size);
      path.quadraticBezierTo(-size * 0.7, 0, 0, -size);
      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    leaf(w * 0.85, h * 0.18, 7, 0.4);
    leaf(w * 0.92, h * 0.30, 5, 0.9);
    leaf(w * 0.95, h * 0.45, 6, 0.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
