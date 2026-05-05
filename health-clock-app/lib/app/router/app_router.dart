import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/navigation/navigation_key.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../features/ai_input/presentation/ai_input_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/calendar/presentation/event_detail_screen.dart';
import '../../features/calendar/presentation/event_form_screen.dart';
import '../../shared/models/health_event.dart';
import '../../features/documents/presentation/document_detail_screen.dart';
import '../../features/documents/presentation/document_list_screen.dart';
import '../../features/documents/presentation/document_upload_screen.dart';
import '../../features/health_records/presentation/metric_form_screen.dart';
import '../../features/health_records/presentation/metric_history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/members/presentation/member_form_screen.dart';
import '../../features/members/presentation/member_list_screen.dart';
import '../../features/members/presentation/member_profile_screen.dart';
import '../../features/notifications/presentation/notification_permission_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/account_center_screen.dart';
import '../../features/settings/presentation/general_settings_screen.dart';
import '../../features/settings/presentation/legal_document_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final auth = ref.watch(authProvider);

  NotificationService.navigatorKey = appNavigatorKey;

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isPublic = loc == '/login' || loc.startsWith('/legal/');
      final authed = auth.status == AuthStatus.authenticated ||
          auth.status == AuthStatus.guest;
      if (!authed && !isPublic) return '/login';
      if (authed && loc == '/login') return '/home';
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
        path: '/members/:id',
        name: 'member-profile',
        builder: (context, state) =>
            MemberProfileScreen(memberId: state.pathParameters['id']!),
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
        path: '/events/:id/edit',
        name: 'event-edit',
        builder: (context, state) {
          // extra 传入完整 HealthEvent 对象
          final event = state.extra as HealthEvent?;
          return EventFormScreen(event: event);
        },
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('我的文档')),
          body: const DocumentListScreen(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/documents/new'),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('上传文档'),
          ),
        ),
      ),
      GoRoute(
        path: '/documents/new',
        name: 'documents-new',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/documents/:id',
        name: 'document-detail',
        builder: (context, state) =>
            DocumentDetailScreen(documentId: state.pathParameters['id']!),
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
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountCenterScreen(),
      ),
      GoRoute(
        path: '/settings/general',
        name: 'settings-general',
        builder: (context, state) => const GeneralSettingsScreen(),
      ),
      GoRoute(
        path: '/legal/terms',
        name: 'legal-terms',
        builder: (context, state) => const LegalDocumentScreen(
          title: '用户协议',
          bodyText: LegalTexts.userTerms,
        ),
      ),
      GoRoute(
        path: '/legal/privacy',
        name: 'legal-privacy',
        builder: (context, state) => const LegalDocumentScreen(
          title: '隐私政策',
          bodyText: LegalTexts.privacyPolicy,
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(child: Text('页面未找到: ${state.uri}')),
    ),
  );
}
