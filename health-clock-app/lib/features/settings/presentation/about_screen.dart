import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            _PageHeader(
              title: '关于我们',
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            const SizedBox(height: AppStyles.spacingM),
            const _BrandCard(),
            const SizedBox(height: AppStyles.spacingM),
            const _IntroCard(
              title: '健康时钟是什么',
              body:
                  '健康时钟是一款面向个人与家庭的健康提醒和档案管理 App。你可以把复查、用药、体检、健康指标和医疗文档集中整理在一个清晰的健康日历里。',
              icon: Icons.favorite_border_rounded,
              color: AppColors.mintDeep,
              bg: AppColors.mintBg,
            ),
            const SizedBox(height: AppStyles.spacingM),
            const _IntroCard(
              title: '我们如何帮助你',
              body:
                  '应用支持按家庭成员管理资料，通过 OCR 和 AI 辅助理解医疗文档，也可以用自然语言快速创建提醒，帮助你少遗漏、少翻找。',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.lavender,
              bg: AppColors.lavenderSoft,
            ),
            const SizedBox(height: AppStyles.spacingM),
            const _NoticeCard(),
          ],
        ),
      ),
    );
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
        _CircleButton(onTap: onBack),
        const SizedBox(width: AppStyles.spacingS),
        Expanded(
          child: Text(
            title,
            style: AppStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppStyles.minTouchTarget,
          height: AppStyles.minTouchTarget,
          alignment: Alignment.center,
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
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.mintBgLight.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.mintBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.mintDeep,
              size: 34,
            ),
          ),
          const SizedBox(height: AppStyles.spacingM),
          Text(
            '健康时钟',
            style: AppStyles.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppStyles.spacingXs),
          Text(
            '家庭健康提醒与档案管理',
            style: AppStyles.footnote.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(icon, color: color, size: 22),
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
                const SizedBox(height: AppStyles.spacingS),
                Text(
                  body,
                  style: AppStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
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

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.mintBgLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Text(
        '健康时钟不提供医学诊断。所有提醒、摘要和趋势仅用于记录与管理，具体医疗建议请以专业医生意见为准。',
        style: AppStyles.footnote.copyWith(
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}
