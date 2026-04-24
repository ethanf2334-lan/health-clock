import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_clock/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HealthClockApp()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('健康时钟'), findsWidgets);
  });
}
