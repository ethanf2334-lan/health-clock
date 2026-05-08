import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../documents/presentation/document_list_screen.dart';
import '../../members/presentation/member_form_screen.dart';
import '../../members/presentation/member_list_screen.dart';
import '../../members/providers/member_provider.dart';
import '../../settings/presentation/profile_screen.dart';
import 'home_calendar_screen.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _index;
  bool _onboardingShown = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOnboarding());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex.clamp(0, 3);
    }
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppStyles.spacingL,
          AppStyles.spacingL,
          AppStyles.spacingL,
          AppStyles.spacingXxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppStyles.spacingXxl,
              height: AppStyles.spacingXs,
              decoration: BoxDecoration(
                color: AppColors.lightOutline,
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
              ),
            ),
            const SizedBox(height: AppStyles.spacingL),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(AppStyles.radiusXl),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                size: AppStyles.spacingXxl,
                color: AppColors.mintDeep,
              ),
            ),
            const SizedBox(height: AppStyles.spacingM),
            Text(
              '欢迎使用健康时钟',
              style: AppStyles.title3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              '先添加您的健康档案，\n之后可以为家庭成员分别管理提醒和数据。',
              textAlign: TextAlign.center,
              style: AppStyles.subhead.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppStyles.spacingXl),
            SizedBox(
              width: double.infinity,
              height: AppStyles.primaryButtonHeight,
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
                  backgroundColor: AppColors.mintDeep,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
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
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: body),
      bottomNavigationBar: HomeBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// 子页面包装：统一白色页面背景。
class _SubPage extends StatelessWidget {
  const _SubPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}
