import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/auth_service.dart';
import '../../features/ai_input/presentation/ai_input_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/calendar/presentation/event_detail_screen.dart';
import '../../features/calendar/presentation/event_form_screen.dart';
import '../../features/documents/presentation/document_list_screen.dart';
import '../../features/documents/presentation/document_upload_screen.dart';
import '../../features/health_records/presentation/metric_form_screen.dart';
import '../../features/health_records/presentation/metric_history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/members/presentation/member_form_screen.dart';
import '../../features/members/presentation/member_list_screen.dart';
import '../../features/notifications/presentation/notification_permission_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final authed = auth.status == AuthStatus.authenticated ||
          auth.status == AuthStatus.guest;
      if (!authed && !loggingIn) return '/login';
      if (authed && loggingIn) return '/home';
      return null;
    },
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
        path: '/members',
        name: 'members',
        builder: (context, state) => const MemberListScreen(),
      ),
      GoRoute(
        path: '/members/new',
        name: 'members-new',
        builder: (context, state) => const MemberFormScreen(),
      ),
      GoRoute(
        path: '/ai-input',
        name: 'ai-input',
        builder: (context, state) => const AIInputScreen(),
      ),
      GoRoute(
        path: '/events/new',
        name: 'events-new',
        builder: (context, state) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        name: 'event-detail',
        builder: (context, state) =>
            EventDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const Scaffold(
          body: DocumentListScreen(),
        ),
      ),
      GoRoute(
        path: '/documents/new',
        name: 'documents-new',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/metrics',
        name: 'metrics',
        builder: (context, state) => const MetricHistoryScreen(),
      ),
      GoRoute(
        path: '/metrics/new',
        name: 'metrics-new',
        builder: (context, state) => const MetricFormScreen(),
      ),
      GoRoute(
        path: '/notifications/permission',
        name: 'notifications-permission',
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(child: Text('页面未找到: ${state.uri}')),
    ),
  );
}
