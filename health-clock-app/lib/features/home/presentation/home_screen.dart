import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../calendar/presentation/event_list_screen.dart';
import '../../documents/presentation/document_list_screen.dart';
import '../../members/presentation/member_list_screen.dart';
import '../../members/presentation/member_switcher.dart';
import '../../settings/presentation/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  final _titles = const ['健康日历', '家庭成员', '健康档案', '我的'];

  @override
  Widget build(BuildContext context) {
    final body = [
      Column(
        children: const [
          MemberSwitcherBar(),
          Expanded(child: EventListScreen()),
        ],
      ),
      const MemberListScreen(),
      Column(
        children: const [
          MemberSwitcherBar(),
          Expanded(child: DocumentListScreen()),
        ],
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: _index == 0
            ? [
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
              ]
            : null,
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
      floatingActionButton: _index == 0
          ? Column(
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
            )
          : null,
    );
  }
}
