import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于健康时钟')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.health_and_safety,
                size: 46,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '健康时钟',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v1.0.0 MVP',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          _section(
            context,
            '我们在解决什么',
            '健康时钟帮助家庭记录健康档案、管理复查和用药提醒，并用 AI 从自然语言、语音和医疗文档中提取健康事项。',
          ),
          _section(
            context,
            '当前能力',
            '手机号/Apple 登录、家庭成员管理、AI 创建提醒、文档 OCR、健康指标趋势、本地通知和日历视图。',
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('项目文档'),
                  subtitle: const Text('docs/健康时钟-MVP项目进度总览.md'),
                  onTap: () => _showText(
                    context,
                    '项目文档',
                    '项目文档在仓库 docs 目录中维护，MVP 进度以“健康时钟-MVP项目进度总览.md”为准。',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隐私说明'),
                  subtitle: const Text('健康数据仅用于本应用核心功能'),
                  onTap: () => _showText(
                    context,
                    '隐私说明',
                    'MVP 阶段不会做广告追踪。上传的健康文档用于 OCR 和 AI 摘要；提醒通知使用设备本地通知。',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('打开项目仓库'),
                  onTap: () => launchUrl(
                    Uri.parse('https://github.com/ethanf2334-lan/health-clock'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  void _showText(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
