import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

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

/// 静态法律文案页（MVP）
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
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.bgGradientStart,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            bodyText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
