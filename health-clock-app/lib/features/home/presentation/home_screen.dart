import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../calendar/presentation/event_list_screen.dart';
import '../../documents/presentation/document_list_screen.dart';
import '../../members/presentation/member_form_screen.dart';
import '../../members/presentation/member_list_screen.dart';
import '../../members/presentation/member_switcher.dart';
import '../../members/providers/member_provider.dart';
import '../../settings/presentation/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;
  bool _onboardingShown = false;

  final _titles = const ['健康日历', '家庭成员', '健康档案', '我的'];

  @override
  void initState() {
    super.initState();
    // 首帧渲染完毕后检测是否需要引导
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.health_and_safety,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '欢迎使用健康时钟',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '先添加您的健康档案，\n之后可以为家庭成员分别管理提醒和数据。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.6),
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
                  // 创建完成后刷新成员列表
                  ref.invalidate(memberListProvider);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('添加我的档案'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
    // 监听成员列表：如果之前是空的现在有数据了，不再需要引导
    ref.listen(memberListProvider, (_, next) {
      next.whenData((members) {
        if (members.isNotEmpty) _onboardingShown = true;
      });
    });
    final body = [
      const Column(
        children: [
          MemberSwitcherBar(),
          Expanded(child: EventListScreen()),
        ],
      ),
      const MemberListScreen(),
      const Column(
        children: [
          MemberSwitcherBar(),
          Expanded(child: DocumentListScreen()),
        ],
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: _buildActions(context),
      ),
      body: IndexedStack(index: _index, children: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '日历',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '成员',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '文档',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (_index == 0) {
      return [
        IconButton(
          tooltip: '记录指标',
          icon: const Icon(Icons.favorite_outline),
          onPressed: () => context.push('/metrics'),
        ),
        IconButton(
          tooltip: '上传文档',
          icon: const Icon(Icons.cloud_upload_outlined),
          onPressed: () => context.push('/documents/new'),
        ),
      ];
    }
    if (_index == 2) {
      return [
        IconButton(
          tooltip: '上传文档',
          icon: const Icon(Icons.cloud_upload_outlined),
          onPressed: () => context.push('/documents/new'),
        ),
      ];
    }
    return null;
  }

  Widget? _buildFab(BuildContext context) {
    if (_index == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_manual',
            tooltip: '手动创建',
            onPressed: () => context.push('/events/new'),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_ai',
            onPressed: () => context.push('/ai-input'),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI 创建'),
          ),
        ],
      );
    }
    if (_index == 2) {
      return FloatingActionButton.extended(
        heroTag: 'fab_upload_document',
        onPressed: () => context.push('/documents/new'),
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('上传文档'),
      );
    }
    return null;
  }
}
