import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
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
      builder: (dialogContext) => _PermissionDialog(
        icon: Icons.delete_sweep_outlined,
        iconColor: AppColors.danger,
        iconBg: AppColors.coralSoft,
        title: '清空本地提醒',
        content: '这会取消当前设备上所有已安排的健康提醒通知。提醒记录本身不会删除。',
        primaryLabel: '清空',
        primaryColor: AppColors.danger,
        onPrimary: () => Navigator.pop(dialogContext, true),
        secondaryLabel: '取消',
        onSecondary: () => Navigator.pop(dialogContext, false),
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
      builder: (dialogContext) => _PermissionDialog(
        icon: Icons.notifications_active_outlined,
        iconColor: AppColors.warmAmber,
        iconBg: AppColors.amberSoft,
        title: '需要通知权限',
        content: '请在系统设置中开启通知权限，以便接收复查、用药等健康提醒。',
        primaryLabel: '去设置',
        primaryColor: AppColors.mintDeep,
        onPrimary: () async {
          Navigator.of(dialogContext).pop();
          await openAppSettings();
        },
        secondaryLabel: '取消',
        onSecondary: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _granted ? AppColors.mintDeep : AppColors.warmAmber;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadStatus,
        child: SafeArea(
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
              _PermissionHeader(
                onBack: () {
                  if (context.canPop()) context.pop();
                },
              ),
              const SizedBox(height: AppStyles.spacingM),
              Container(
                padding: const EdgeInsets.all(AppStyles.cardPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusL),
                  border: Border.all(color: AppColors.lightOutline),
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _granted
                            ? Icons.notifications_active
                            : Icons.notifications_off_outlined,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: AppStyles.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _granted ? '通知已开启' : '通知未开启',
                            style: AppStyles.subhead.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppStyles.spacingXs),
                          Text(
                            _granted ? '健康提醒会按你设置的时间触发。' : '开启后才能收到复查、用药等健康提醒。',
                            style: AppStyles.footnote.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.spacingM),
              _PermissionCard(
                children: [
                  _PermissionTile(
                    icon: Icons.pending_actions_outlined,
                    title: '已安排提醒',
                    subtitle: '当前设备上有 $_pendingCount 条待触发通知',
                  ),
                  _PermissionTile(
                    icon: Icons.notifications_active_outlined,
                    title: _granted ? '重新检查通知权限' : '开启通知权限',
                    onTap: _isRequesting ? null : _requestPermission,
                    trailing: _isRequesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                  ),
                  _PermissionTile(
                    icon: Icons.send_outlined,
                    title: '发送测试通知',
                    subtitle: '约 5 秒后收到一条测试提醒',
                    onTap: _sendTestNotification,
                  ),
                  const _PermissionTile(
                    icon: Icons.settings_outlined,
                    title: '打开系统设置',
                    onTap: openAppSettings,
                  ),
                  _PermissionTile(
                    icon: Icons.delete_sweep_outlined,
                    title: '清空本地提醒',
                    subtitle: '只取消通知，不删除提醒记录',
                    iconColor: AppColors.danger,
                    onTap: _pendingCount == 0 ? null : _cancelAll,
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.spacingM),
              Text(
                '说明：健康时钟使用 iOS 本地通知。重新安装 App、系统权限关闭或设备重启后的系统限制，都可能影响提醒触发。',
                style: AppStyles.footnote.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionHeader extends StatelessWidget {
  const _PermissionHeader({required this.onBack});

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
            child: const SizedBox(
              width: AppStyles.minTouchTarget,
              height: AppStyles.minTouchTarget,
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Text(
          '通知设置',
          style: AppStyles.screenTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.children});

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

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor = AppColors.mintDeep,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconColor;

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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
              ),
              child: Icon(icon, color: iconColor, size: 20),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: AppStyles.spacingXs),
                    Text(
                      subtitle!,
                      style: AppStyles.footnote.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.content,
    required this.primaryLabel,
    required this.primaryColor,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String content;
  final String primaryLabel;
  final Color primaryColor;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.headline.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              content,
              style: AppStyles.footnote.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.lightOutline),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppStyles.radiusFull),
                      ),
                    ),
                    child: Text(secondaryLabel),
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppStyles.radiusFull),
                      ),
                    ),
                    child: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
