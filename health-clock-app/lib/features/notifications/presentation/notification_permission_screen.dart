import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/notification_service.dart';

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends ConsumerState<NotificationPermissionScreen> {
  bool _isRequesting = false;
  bool _granted = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final service = NotificationService();
    final granted = await service.checkPermission();
    final pending = await service.getPendingNotifications();
    if (!mounted) return;
    setState(() {
      _granted = granted;
      _pendingCount = pending.length;
    });
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    final granted = await NotificationService().requestPermission();

    if (!mounted) return;
    setState(() => _isRequesting = false);
    await _loadStatus();

    if (granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('通知权限已开启')),
      );
    } else if (mounted) {
      _showSettingsDialog();
    }
  }

  Future<void> _sendTestNotification() async {
    if (!_granted) {
      await _requestPermission();
      if (!_granted) return;
    }

    await NotificationService().scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
      title: '健康时钟测试提醒',
      body: '如果你看到这条通知，说明提醒功能可以正常工作。',
      scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
    );
    await _loadStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试通知已安排，约 5 秒后触发')),
    );
  }

  Future<void> _cancelAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空本地提醒'),
        content: const Text('这会取消当前设备上所有已安排的健康提醒通知。提醒记录本身不会删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await NotificationService().cancelAllNotifications();
    await _loadStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清空本地提醒')),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要通知权限'),
        content: const Text('请在系统设置中开启通知权限，以便接收健康提醒。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _granted ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(title: const Text('通知设置')),
      body: RefreshIndicator(
        onRefresh: _loadStatus,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      child: Icon(
                        _granted
                            ? Icons.notifications_active
                            : Icons.notifications_off_outlined,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _granted ? '通知已开启' : '通知未开启',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _granted ? '健康提醒会按你设置的时间触发。' : '开启后才能收到复查、用药等健康提醒。',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.pending_actions_outlined),
              title: const Text('已安排提醒'),
              subtitle: Text('当前设备上有 $_pendingCount 条待触发通知'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(_granted ? '重新检查通知权限' : '开启通知权限'),
              trailing: _isRequesting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isRequesting ? null : _requestPermission,
            ),
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: const Text('发送测试通知'),
              subtitle: const Text('约 5 秒后收到一条测试提醒'),
              onTap: _sendTestNotification,
            ),
            const ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('打开系统设置'),
              onTap: openAppSettings,
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('清空本地提醒'),
              subtitle: const Text('只取消通知，不删除提醒记录'),
              onTap: _pendingCount == 0 ? null : _cancelAll,
            ),
            const SizedBox(height: 24),
            Text(
              '说明：健康时钟使用 iOS 本地通知。重新安装 App、系统权限关闭或设备重启后的系统限制，都可能影响提醒触发。',
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
