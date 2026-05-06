import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_clock/core/services/auth_service.dart';
import 'package:health_clock/features/settings/presentation/profile_screen.dart';
import 'package:health_clock/main.dart';

void main() {
  testWidgets('App launches and shows login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HealthClockApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('健康时钟'), findsWidgets);
  });

  testWidgets('Profile screen fits iPhone 17 width without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _TestAuth(
              const AuthState(
                status: AuthStatus.authenticated,
                userId: 'test-user',
                phone: '15612348888',
                email: 'lan@example.com',
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SafeArea(child: ProfileScreen())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('登录与账号'), findsOneWidget);
  });
}

class _TestAuth extends Auth {
  _TestAuth(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}
