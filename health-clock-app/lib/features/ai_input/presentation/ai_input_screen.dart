import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_quick_create_panel.dart';

class AIInputScreen extends ConsumerWidget {
  const AIInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 创建提醒'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AIQuickCreatePanel(),
      ),
    );
  }
}
