import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text('通用设置'),
        backgroundColor: AppColors.bgGradientStart,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            elevation: 0,
            color: AppColors.cardWhite,
            child: Column(
              children: [
                ListTile(
                  title: const Text('语言'),
                  trailing: Text(
                    '跟随系统',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('清除缓存'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('MVP 阶段暂无本地缓存清理')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
