import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../documents/presentation/document_list_screen.dart';
import '../../members/presentation/member_form_screen.dart';
import '../../members/presentation/member_list_screen.dart';
import '../../members/providers/member_provider.dart';
import '../../settings/presentation/profile_screen.dart';
import 'home_calendar_screen.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _onboardingShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboarding());
  }

  Future<void> _checkOnboarding() async {
    if (_onboardingShown) return;
    final membersAsync = ref.read(memberListProvider);
    membersAsync.whenData((members) {
      if (members.isEmpty && mounted) {
        _onboardingShown = true;
        _showOnboardingSheet();
      }
    });
  }

  void _showOnboardingSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightOutline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                size: 40,
                color: AppColors.mintDeep,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '欢迎使用健康时钟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '先添加您的健康档案，\n之后可以为家庭成员分别管理提醒和数据。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MemberFormScreen(),
                    ),
                  );
                  ref.invalidate(memberListProvider);
                },
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('添加我的档案'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.mintDeep,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('稍后再说'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(memberListProvider, (_, next) {
      next.whenData((members) {
        if (members.isNotEmpty) _onboardingShown = true;
      });
    });

    final body = [
      const HomeCalendarScreen(),
      const _SubPage(child: MemberListScreen(showAppBar: false)),
      const _SubPage(child: DocumentListScreen()),
      const _SubPage(child: ProfileScreen()),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      body: IndexedStack(index: _index, children: body),
      bottomNavigationBar: HomeBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// 子页面包装：保留浅薄荷绿渐变 + AppBar
class _SubPage extends StatelessWidget {
  const _SubPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgGradientStart,
            AppColors.bgGradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}
