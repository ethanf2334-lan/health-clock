import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';

class AccountCenterScreen extends ConsumerWidget {
  const AccountCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final phone = auth.phone ?? '';
    final email = auth.email;

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        title: const Text('登录与账号'),
        backgroundColor: AppColors.bgGradientStart,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: AppColors.cardWhite,
            child: Column(
              children: [
                ListTile(
                  title: const Text('手机号'),
                  subtitle: Text(
                    phone.isEmpty ? '未绑定' : _maskPhone(phone),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('邮箱 / Apple'),
                  subtitle: Text(email ?? '未绑定'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '更换绑定方式等功能将在后续版本开放。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _maskPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length < 11) return raw;
    final p = d.length > 11 ? d.substring(d.length - 11) : d;
    return '${p.substring(0, 3)}****${p.substring(7)}';
  }
}
