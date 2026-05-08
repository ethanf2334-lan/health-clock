import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _SettingsHeader(
              title: '通用设置',
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            const SizedBox(height: AppStyles.spacingM),
            _SettingsCard(
              children: [
                const _SettingsTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.careBlue,
                  iconBg: AppColors.careBlueSoft,
                  title: '语言',
                  value: '跟随系统',
                ),
                _SettingsTile(
                  icon: Icons.cleaning_services_outlined,
                  iconColor: AppColors.warmAmber,
                  iconBg: AppColors.amberSoft,
                  title: '清除缓存',
                  value: '暂无缓存',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('MVP 阶段暂无本地缓存清理')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title, required this.onBack});

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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: Padding(
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
              child: Text(
                title,
                style: AppStyles.subhead.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppStyles.spacingXs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
