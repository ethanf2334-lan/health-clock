import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../core/services/auth_service.dart';

class AccountCenterScreen extends ConsumerWidget {
  const AccountCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final phone = auth.phone ?? '';
    final appleAccount = _appleAccountLabel(auth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppStyles.screenMargin,
            AppStyles.spacingS,
            AppStyles.screenMargin,
            AppStyles.spacingL + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _PageHeader(
              title: '登录与账号',
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            const SizedBox(height: AppStyles.spacingM),
            _AccountSummary(
              title: auth.status == AuthStatus.guest ? '体验用户' : '账号已登录',
              subtitle: auth.status == AuthStatus.guest
                  ? '当前为体验模式，登录后可同步保存健康资料。'
                  : '账号信息用于登录和保护你的健康资料。',
            ),
            const SizedBox(height: AppStyles.spacingM),
            _AccountCard(
              children: [
                _AccountTile(
                  icon: Icons.phone_iphone_rounded,
                  iconColor: AppColors.mintDeep,
                  iconBg: AppColors.mintBg,
                  title: '手机号',
                  subtitle: phone.isEmpty ? '未绑定' : _maskPhone(phone),
                ),
                _AccountTile(
                  icon: Icons.apple_rounded,
                  iconColor: AppColors.textPrimary,
                  iconBg: AppColors.lightSurface,
                  title: '邮箱 / Apple',
                  subtitle: appleAccount,
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              '更换绑定方式等功能将在后续版本开放。',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length < 11) return raw;
    final p = d.length > 11 ? d.substring(d.length - 11) : d;
    return '${p.substring(0, 3)}****${p.substring(7)}';
  }

  String _appleAccountLabel(AuthState auth) {
    final email = auth.email;
    if (email != null && email.isNotEmpty) return email;
    if (auth.provider == 'apple') {
      final identifier = auth.appleUserIdentifier;
      if (identifier != null && identifier.length >= 8) {
        return 'Apple 已登录 · ${identifier.substring(0, 4)}…${identifier.substring(identifier.length - 4)}';
      }
      return 'Apple 已登录';
    }
    if (auth.status == AuthStatus.authenticated &&
        (auth.phone == null || auth.phone!.isEmpty)) {
      return 'Apple 已登录';
    }
    return '未绑定';
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppStyles.minTouchTarget,
              height: AppStyles.minTouchTarget,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightOutline),
                    boxShadow: AppStyles.subtleShadow,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Text(
          title,
          style: AppStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.mintBgLight],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.mintBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.mintDeep,
              size: 22,
            ),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                Text(
                  subtitle,
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: AppStyles.dividerThin,
                color: AppColors.lightDivider,
                indent: 64,
              ),
          ],
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.spacingM),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppStyles.spacingXs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
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
