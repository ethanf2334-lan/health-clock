import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.status == AuthStatus.guest;

    final displayName = isGuest
        ? '测试用户'
        : (auth.phone ?? auth.email ?? (auth.userId ?? '用户'));

    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        if (isGuest)
          Center(
            child: Text('未登录（测试模式）',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('家庭成员'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/members'),
        ),
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: const Text('我的文档'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/documents'),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: const Text('健康指标'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/metrics'),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_none),
          title: const Text('通知设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/notifications/permission'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于'),
          subtitle: const Text('健康时钟 v1.0.0'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: '健康时钟',
              applicationVersion: '1.0.0',
              children: [
                const Text('基于 AI 的家庭健康提醒与档案管理。'),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(isGuest ? '退出测试' : '退出登录'),
                  content: Text(isGuest ? '回到登录界面？' : '确定退出当前账号？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(authProvider.notifier).signOut();
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(isGuest ? '退出测试' : '退出登录',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
