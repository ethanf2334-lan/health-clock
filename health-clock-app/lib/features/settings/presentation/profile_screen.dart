import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import 'widgets/profile_header_bar.dart';
import 'widgets/profile_membership_banner.dart';
import 'widgets/profile_menu_card.dart';
import 'widgets/profile_service_grid.dart';
import 'widgets/profile_user_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.status == AuthStatus.guest;

    final displayName = _displayName(auth);
    final phoneLine = _phoneLine(auth);
    final bindingLine = _bindingLine(auth);
    final accountOk = !isGuest;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgGradientStart,
            Color(0xFFFFFEFC),
          ],
          stops: [0.0, 0.22],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ProfileHeaderBar(
            title: '我的',
            onNotificationTap: () => context.push('/notifications/permission'),
            onSettingsTap: () => context.push('/settings/general'),
          ),
          ProfileUserCard(
            name: displayName,
            phoneDisplay: phoneLine,
            bindingHint: bindingLine,
            accountOk: accountOk,
            onManageAccountTap: () => context.push('/account'),
          ),
          ProfileMembershipBanner(
            onViewBenefits: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('会员权益即将开放')),
              );
            },
          ),
          ProfileServiceGrid(
            onIndicators: () => context.push('/metrics'),
            onDocuments: () => context.push('/documents'),
            onNotifications: () => context.push('/notifications/permission'),
            onMembers: () => context.push('/members'),
          ),
          ProfileMenuCard(
            children: [
              ProfileMenuTile(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.mintDeep,
                iconBg: AppColors.mintSoft,
                title: '登录与账号',
                onTap: () => context.push('/account'),
              ),
              ProfileMenuTile(
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.mintDeep,
                iconBg: AppColors.mintSoft,
                title: '家庭成员管理',
                onTap: () => context.push('/members'),
              ),
              ProfileMenuTile(
                icon: Icons.monitor_heart_rounded,
                iconColor: AppColors.careBlue,
                iconBg: AppColors.careBlueSoft,
                title: '健康指标',
                onTap: () => context.push('/metrics'),
              ),
              ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                iconColor: AppColors.warmAmber,
                iconBg: AppColors.amberSoft,
                title: '通知设置',
                onTap: () => context.push('/notifications/permission'),
              ),
              ProfileMenuTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.careBlue,
                iconBg: AppColors.careBlueSoft,
                title: '帮助与反馈',
                onTap: () => _showHelp(context),
              ),
              ProfileMenuTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.mintDeep,
                iconBg: AppColors.mintSoft,
                title: '关于我们',
                onTap: () => context.push('/about'),
              ),
              ProfileMenuTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.lavender,
                iconBg: AppColors.lavenderSoft,
                title: '隐私政策',
                onTap: () => context.push('/legal/privacy'),
              ),
              ProfileMenuTile(
                icon: Icons.article_outlined,
                iconColor: AppColors.careBlue,
                iconBg: AppColors.careBlueSoft,
                title: '用户协议',
                onTap: () => context.push('/legal/terms'),
              ),
              ProfileMenuTile(
                icon: Icons.settings_outlined,
                iconColor: AppColors.textSecondary,
                iconBg: AppColors.lightDivider,
                title: '通用设置',
                onTap: () => context.push('/settings/general'),
              ),
              ProfileMenuTile(
                icon: Icons.logout_rounded,
                iconColor: AppColors.danger,
                iconBg: const Color(0xFFFFE8EC),
                title: isGuest ? '退出体验' : '退出登录',
                titleColor: AppColors.danger,
                trailing: const SizedBox.shrink(),
                onTap: () => _confirmSignOut(context, ref, isGuest),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '健康时钟 v1.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(AuthState auth) {
    if (auth.status == AuthStatus.guest) return '体验用户';
    final phone = auth.phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (phone.length >= 4) {
      return '用户${phone.substring(phone.length - 4)}';
    }
    if (auth.email != null && auth.email!.isNotEmpty) {
      return auth.email!.split('@').first;
    }
    return '健康用户';
  }

  String _phoneLine(AuthState auth) {
    if (auth.status == AuthStatus.guest) return '130****8888';
    final p = auth.phone;
    if (p == null || p.isEmpty) return '未绑定手机号';
    return _maskPhone(p);
  }

  String _bindingLine(AuthState auth) {
    if (auth.status == AuthStatus.guest) {
      return '访客模式 · 数据仅保存在本机演示';
    }
    final hasPhone = auth.phone != null && auth.phone!.isNotEmpty;
    final hasEmail = auth.email != null && auth.email!.isNotEmpty;
    if (hasPhone && hasEmail) return '手机号登录 / Apple 已绑定';
    if (hasPhone) return '手机号登录';
    if (hasEmail) return 'Apple 或第三方账号';
    return '请完善账号信息';
  }

  String _maskPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length < 11) return raw;
    final p = d.length > 11 ? d.substring(d.length - 11) : d;
    return '${p.substring(0, 3)}****${p.substring(7)}';
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('帮助与反馈'),
        content: const Text(
          '如遇问题，请通过项目仓库 issue 与我们联系，或在「关于我们」中查看文档入口。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    bool isGuest,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isGuest ? '退出体验' : '退出登录'),
        content: Text(isGuest ? '回到登录界面？' : '确定退出当前账号？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '确定',
              style: TextStyle(color: isGuest ? null : AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}
