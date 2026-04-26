import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// 全局 NavigatorKey，由 app_router.dart 注入，用于从通知回调中导航。
  static GlobalKey<NavigatorState>? navigatorKey;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// 请求通知权限
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// 检查通知权限状态
  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// 调度单次通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // 转换为 TZDateTime
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// 根据提醒重复规则调度通知。未设置重复规则时调度单次通知。
  Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required DateTime scheduledDate,
    Map<String, dynamic>? repeatRule,
    String? payload,
  }) async {
    final frequency = repeatRule?['frequency'] as String?;
    final interval = (repeatRule?['interval'] as num?)?.toInt() ?? 1;

    if (frequency == null || interval != 1) {
      await scheduleNotification(
        id: id,
        title: title,
        body: '健康时钟提醒',
        scheduledDate: scheduledDate,
        payload: payload,
      );
      return;
    }

    DateTimeComponents? components;
    switch (frequency) {
      case 'daily':
        components = DateTimeComponents.time;
        break;
      case 'weekly':
        components = DateTimeComponents.dayOfWeekAndTime;
        break;
      case 'monthly':
        components = DateTimeComponents.dayOfMonthAndTime;
        break;
      default:
        components = null;
    }

    if (components == null) {
      await scheduleNotification(
        id: id,
        title: title,
        body: '健康时钟提醒',
        scheduledDate: scheduledDate,
        payload: payload,
      );
      return;
    }

    const notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      '健康时钟提醒',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: components,
      payload: payload,
    );
  }

  /// 取消通知
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 通知点击回调：payload 格式为 "event:<id>"
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final context = navigatorKey?.currentContext;
    if (context == null) return;

    if (payload.startsWith('event:')) {
      final id = payload.substring('event:'.length);
      // 使用 GoRouter 进行路由跳转
      _navigateToEvent(context, id);
    }
  }

  void _navigateToEvent(BuildContext context, String eventId) {
    // GoRouter 通过 context extension 导航
    try {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).push('/events/$eventId');
    } catch (_) {
      // 路由不可用时忽略
    }
  }
}
