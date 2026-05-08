import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';

class HelpFeedbackScreen extends StatelessWidget {
  const HelpFeedbackScreen({super.key});

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
            _HelpHeader(
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            const SizedBox(height: AppStyles.spacingM),
            const _FeedbackHero(),
            const SizedBox(height: AppStyles.spacingM),
            const _HelpSection(
              title: '常见问题',
              children: [
                _HelpItem(
                  icon: Icons.notifications_none_rounded,
                  title: '收不到提醒怎么办？',
                  body: '请先确认系统通知权限已开启，并在通知设置中重新检查权限或发送一条测试通知。',
                ),
                _HelpItem(
                  icon: Icons.document_scanner_outlined,
                  title: '文档 OCR 识别不准确？',
                  body: '建议上传清晰、完整、无遮挡的图片或 PDF。识别结果仅用于整理资料，重要内容请以原件为准。',
                ),
                _HelpItem(
                  icon: Icons.group_outlined,
                  title: '如何区分家人的资料？',
                  body: '提醒、文档和指标都会按当前成员隔离。创建或上传前，请先确认顶部当前成员是否正确。',
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            const _FeedbackCard(),
          ],
        ),
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.onBack});

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
        Expanded(
          child: Text(
            '帮助与反馈',
            style: AppStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackHero extends StatelessWidget {
  const _FeedbackHero();

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
              Icons.support_agent_rounded,
              color: AppColors.mintDeep,
              size: 24,
            ),
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Text(
              '遇到问题、看不懂识别结果，或有想改进的地方，都可以先在这里查看说明。',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.title, required this.children});

  final String title;
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
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.mintDeep,
                  size: 20,
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.subhead.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingS,
        AppStyles.spacingM,
        AppStyles.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.mintBgLight,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Icon(icon, color: AppColors.mintDeep, size: 20),
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

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.mintBgLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_note_rounded,
            color: AppColors.mintDeep,
            size: 24,
          ),
          const SizedBox(width: AppStyles.spacingM),
          Expanded(
            child: Text(
              '在线反馈入口正在准备中。当前版本可以先通过应用内设置页查看常见说明，后续会支持直接提交问题和建议。',
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
