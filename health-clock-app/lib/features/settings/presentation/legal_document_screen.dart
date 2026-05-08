import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';

class LegalTexts {
  LegalTexts._();

  static const userTerms = '欢迎使用健康时钟。\n\n'
      '在使用本应用前，请仔细阅读本协议。您注册、登录或以其他方式使用即视为已充分理解并同意接受本协议的全部内容。\n\n'
      '1. 服务内容：本应用提供家庭健康提醒、档案管理、文档 OCR 与 AI 辅助等信息服务。\n'
      '2. 账号与安全：请妥善保管手机号验证登录信息；若通过 Apple 登录，将遵循相应授权范围。\n'
      '3. 用户行为规范：不得利用本服务从事违法或侵害他人合法权益的行为。\n'
      '4. 协议变更：我们可能根据业务发展适时修订本协议，修订后在应用内提示即视为送达。';

  static const privacyPolicy = '健康时钟重视您的隐私保护。\n\n'
      '1. 我们收集的信息：包括账号信息（手机号、Apple 登录标识）、您主动录入的家庭成员与健康数据、您上传的医疗文档等。\n'
      '2. 使用目的：用于提供提醒、OCR 解析、AI 摘要与产品改进等核心功能。\n'
      '3. 存储与安全：我们采用合理的技术与管理措施保护数据安全；MVP 阶段不做广告追踪。\n'
      '4. 您的权利：您可在应用内管理成员与文档；如需删除账号相关数据，可通过帮助与反馈联系我们。';
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.bodyText,
  });

  final String title;
  final String bodyText;

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
            _LegalHeader(
              title: title,
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            const SizedBox(height: AppStyles.spacingM),
            _LegalCard(title: title, bodyText: bodyText),
          ],
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({required this.title, required this.onBack});

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

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.title, required this.bodyText});

  final String title;
  final String bodyText;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.mintBg,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Icon(
                  title == '隐私政策'
                      ? Icons.privacy_tip_outlined
                      : Icons.description_outlined,
                  color: AppColors.mintDeep,
                  size: 20,
                ),
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
          const SizedBox(height: AppStyles.spacingM),
          Text(
            bodyText,
            style: AppStyles.footnote.copyWith(
              height: 1.62,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
