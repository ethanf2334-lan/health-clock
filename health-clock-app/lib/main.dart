import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
  } catch (_) {
    // 时区不可用时忽略，使用系统默认。
  }

  try {
    await initSupabase();
  } catch (_) {
    // Supabase 未配置或初始化失败时，走测试模式。
  }

  try {
    await NotificationService().initialize();
  } catch (_) {
    // 测试环境可能不支持，忽略。
  }

  runApp(
    const ProviderScope(
      child: HealthClockApp(),
    ),
  );
}

class HealthClockApp extends ConsumerWidget {
  const HealthClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '健康时钟',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
    );
  }
}
