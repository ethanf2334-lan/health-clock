import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../members/presentation/widgets/member_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _green = Color(0xFF19A760);
  static const _orange = Color(0xFFFFA300);
  static const _blue = Color(0xFF5597FF);
  static const _purple = Color(0xFF7669FF);
  static const _red = Color(0xFFE53935);
  static const _line = Color(0xFFEAEFEB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.status == AuthStatus.guest;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FCF9),
            Color(0xFFF9FCFA),
            Colors.white,
          ],
          stops: [0, .42, 1],
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppStyles.spacingM,
          AppStyles.spacingM,
          AppStyles.spacingM,
          AppStyles.spacingL,
        ),
        children: [
          _Header(
            onNotificationTap: () => context.push('/notifications/permission'),
            onSettingsTap: () => context.push('/settings/general'),
          ),
          const SizedBox(height: AppStyles.spacingL),
          _ProfileCard(
            name: _displayName(auth),
            phoneDisplay: _phoneLine(auth),
            bindingLine: _bindingLine(auth),
            accountOk: !isGuest,
            onTap: () => context.push('/account'),
          ),
          const SizedBox(height: AppStyles.spacingL),
          _MenuCard(
            children: [
              _MenuTile(
                icon: Icons.person_add_alt_1_outlined,
                iconColor: _green,
                title: '登录与账号',
                onTap: () => context.push('/account'),
              ),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                iconColor: _orange,
                title: '通知设置',
                onTap: () => context.push('/notifications/permission'),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          _MenuCard(
            children: [
              _MenuTile(
                icon: Icons.help_outline_rounded,
                iconColor: _blue,
                title: '帮助与反馈',
                onTap: () => context.push('/help-feedback'),
              ),
              _MenuTile(
                icon: Icons.info_outline_rounded,
                iconColor: _green,
                title: '关于我们',
                onTap: () => context.push('/about'),
              ),
              _MenuTile(
                icon: Icons.verified_user_outlined,
                iconColor: _purple,
                title: '隐私政策',
                onTap: () => context.push('/legal/privacy'),
              ),
              _MenuTile(
                icon: Icons.description_outlined,
                iconColor: _blue,
                title: '用户协议',
                onTap: () => context.push('/legal/terms'),
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                iconColor: AppColors.textTertiary,
                title: '通用设置',
                onTap: () => context.push('/settings/general'),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacingM),
          _LogoutButton(
            label: isGuest ? '退出体验' : '退出登录',
            onTap: () => _confirmSignOut(context, ref, isGuest),
          ),
        ],
      ),
    );
  }

  String _displayName(AuthState auth) {
    if (auth.status == AuthStatus.guest) return '体验用户';
    if (auth.email != null && auth.email!.isNotEmpty) {
      return auth.email!.split('@').first;
    }
    final phone = auth.phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (phone.length >= 4) return '用户${phone.substring(phone.length - 4)}';
    return '健康用户';
  }

  String _phoneLine(AuthState auth) {
    if (auth.status == AuthStatus.guest) return '130****8888';
    final p = auth.phone;
    if (p == null || p.isEmpty) return '未绑定手机号';
    return _maskPhone(p);
  }

  String _bindingLine(AuthState auth) {
    if (auth.status == AuthStatus.guest) return 'Apple 已绑定';
    final hasPhone = auth.phone != null && auth.phone!.isNotEmpty;
    final hasEmail = auth.email != null && auth.email!.isNotEmpty;
    if (hasPhone && hasEmail) return 'Apple 已绑定';
    if (hasEmail) return 'Apple 已绑定';
    if (hasPhone) return '手机号登录';
    return '请完善账号信息';
  }

  String _maskPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length < 11) return raw;
    final p = d.length > 11 ? d.substring(d.length - 11) : d;
    return '${p.substring(0, 3)}****${p.substring(7)}';
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    bool isGuest,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AppDialog(
        icon: Icons.logout_rounded,
        iconColor: _red,
        iconBg: AppColors.coralSoft,
        title: isGuest ? '退出体验' : '退出登录',
        content: isGuest ? '确认回到登录界面吗？' : '确认退出当前账号吗？退出后仍可再次登录。',
        primaryLabel: '确定',
        primaryColor: isGuest ? AppColors.mintDeep : _red,
        onPrimary: () => Navigator.pop(dialogContext, true),
        secondaryLabel: '取消',
        onSecondary: () => Navigator.pop(dialogContext, false),
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.primaryLabel,
    required this.onPrimary,
    this.iconBg,
    this.primaryColor = AppColors.mintDeep,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final String title;
  final String content;
  final String primaryLabel;
  final Color primaryColor;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg ?? iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              content,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            Row(
              children: [
                if (secondaryLabel != null && onSecondary != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.lightOutline),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppStyles.radiusFull),
                        ),
                      ),
                      child: Text(secondaryLabel!),
                    ),
                  ),
                  const SizedBox(width: AppStyles.spacingS),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppStyles.radiusFull),
                      ),
                    ),
                    child: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '我的',
            style: AppStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _HeaderIcon(
          icon: Icons.notifications_none_rounded,
          showDot: true,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: AppStyles.spacingM),
        _HeaderIcon(
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
      child: SizedBox(
        width: AppStyles.minTouchTarget,
        height: AppStyles.minTouchTarget,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 28),
            if (showDot)
              Positioned(
                right: 4,
                top: 3,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.phoneDisplay,
    required this.bindingLine,
    required this.accountOk,
    required this.onTap,
  });

  final String name;
  final String phoneDisplay;
  final String bindingLine;
  final bool accountOk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusXl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final avatarSize = compact ? 72.0 : 80.0;
          final artWidth = compact ? 78.0 : 88.0;
          final artRightInset = compact ? -12.0 : -8.0;
          final textRightInset = compact ? 40.0 : 56.0;

          return Container(
            height: 128,
            padding: EdgeInsets.fromLTRB(
              AppStyles.spacingM,
              AppStyles.spacingM,
              compact ? AppStyles.spacingS : AppStyles.spacingM,
              AppStyles.spacingM,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyles.radiusXl),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7FFFB), Color(0xFFEFFAF4)],
              ),
              border: Border.all(color: const Color(0xFFDCEBE4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D8B66).withValues(alpha: .10),
                  blurRadius: 16,
                  offset: const Offset(0, AppStyles.spacingS),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: artRightInset,
                  top: 7,
                  bottom: 2,
                  child: IgnorePointer(
                    child: _ShieldArt(width: artWidth),
                  ),
                ),
                Row(
                  children: [
                    _PortraitAvatar(size: avatarSize),
                    SizedBox(
                      width: compact ? AppStyles.spacingS : AppStyles.spacingM,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: textRightInset),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppStyles.headline.fontSize,
                                      height: 1.15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (accountOk) ...[
                                  const SizedBox(width: 6),
                                  const Flexible(child: _AccountBadge()),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppStyles.spacingS),
                            Text(
                              phoneDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppStyles.subhead.fontSize,
                                height: 1.1,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppStyles.spacingS),
                            Row(
                              children: [
                                const Icon(
                                  Icons.apple_rounded,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(width: AppStyles.spacingXs),
                                Expanded(
                                  child: Text(
                                    bindingLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppStyles.footnote.fontSize,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountBadge extends StatelessWidget {
  const _AccountBadge();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF7E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: ProfileScreen._green,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              '账号正常',
              style: TextStyle(
                fontSize: 11.5,
                height: 1,
                fontWeight: FontWeight.w600,
                color: ProfileScreen._green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: const Color(0xFFE9F0EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, AppStyles.spacingXs),
          ),
        ],
      ),
      child: Column(children: _withDividers(children)),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          const Padding(
            padding: EdgeInsets.only(left: 64, right: 32),
            child: Divider(height: 1, color: ProfileScreen._line),
          ),
        );
      }
    }
    return result;
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppStyles.spacingL),
            SizedBox(
              width: AppStyles.spacingXl,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.subhead.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(width: AppStyles.spacingL),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: Container(
        height: AppStyles.primaryButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          color: const Color(0xFFFFFAF9),
          border: Border.all(color: const Color(0xFFFFD9D7)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withValues(alpha: .035),
              blurRadius: 12,
              offset: const Offset(0, AppStyles.spacingXs),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: ProfileScreen._red,
              size: 22,
            ),
            const SizedBox(width: AppStyles.spacingS),
            Text(
              label,
              style: AppStyles.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: ProfileScreen._red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortraitAvatar extends StatelessWidget {
  const _PortraitAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return MemberAvatar(
      name: '用户',
      relation: 'self',
      size: size,
      borderColor: Colors.white,
      borderWidth: 4,
    );
  }
}

class _ShieldArt extends StatelessWidget {
  const _ShieldArt({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 112,
      child: CustomPaint(painter: _ShieldPainter()),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF77D69E).withValues(alpha: .42);
    final stemPaint = Paint()
      ..color = const Color(0xFF77D69E).withValues(alpha: .5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void leaf(double x, double y, double rot, double scale) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.scale(scale);
      final path = Path()
        ..moveTo(0, -9)
        ..quadraticBezierTo(13, 0, 0, 10)
        ..quadraticBezierTo(-13, 0, 0, -9)
        ..close();
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }

    for (final side in [-1, 1]) {
      final baseX = size.width * .50 + side * 32;
      canvas.drawLine(
        Offset(baseX, size.height * .82),
        Offset(baseX + side * 10, size.height * .34),
        stemPaint,
      );
      leaf(baseX + side * 5, size.height * .62, side * .65, .66);
      leaf(baseX + side * 11, size.height * .47, side * .55, .58);
      leaf(baseX + side * 15, size.height * .32, side * .45, .52);
    }

    final cloud = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * .50, 28), 24, cloud);
    canvas.drawCircle(Offset(size.width * .69, 39), 18, cloud);
    canvas.drawCircle(Offset(size.width * .32, 42), 18, cloud);

    final shield = Path()
      ..moveTo(size.width * .50, 32)
      ..quadraticBezierTo(size.width * .72, 42, size.width * .74, 53)
      ..quadraticBezierTo(size.width * .72, 83, size.width * .50, 99)
      ..quadraticBezierTo(size.width * .28, 83, size.width * .26, 53)
      ..quadraticBezierTo(size.width * .28, 42, size.width * .50, 32)
      ..close();
    canvas.drawShadow(
      shield,
      const Color(0xFF2FAE69).withValues(alpha: .16),
      8,
      false,
    );
    canvas.drawPath(shield, Paint()..color = const Color(0xFF96E1B4));
    canvas.drawPath(
      shield.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.white.withValues(alpha: .48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final inner = Path()
      ..moveTo(size.width * .50, 44)
      ..quadraticBezierTo(size.width * .64, 51, size.width * .66, 59)
      ..quadraticBezierTo(size.width * .64, 81, size.width * .50, 91)
      ..quadraticBezierTo(size.width * .36, 81, size.width * .34, 59)
      ..quadraticBezierTo(size.width * .36, 51, size.width * .50, 44)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFF6FFF9));

    final tick = Paint()
      ..color = const Color(0xFF72CEA0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(
      Offset(size.width * .42, size.height * .59),
      Offset(size.width * .49, size.height * .67),
      tick,
    );
    canvas.drawLine(
      Offset(size.width * .49, size.height * .67),
      Offset(size.width * .63, size.height * .50),
      tick,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
