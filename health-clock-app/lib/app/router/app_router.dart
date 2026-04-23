import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/ai_input/presentation/ai_input_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/members/presentation/member_list_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/members',
        name: 'members',
        builder: (context, state) => const MemberListScreen(),
      ),
      GoRoute(
        path: '/ai-input',
        name: 'ai-input',
        builder: (context, state) => const AIInputScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Text('页面未找到: ${state.uri}'),
      ),
    ),
  );
}
