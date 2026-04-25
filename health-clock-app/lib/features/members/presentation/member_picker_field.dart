import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/member_provider.dart';

/// 表单里用的成员下拉，返回选中的成员 ID。
class MemberPickerField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool required;

  const MemberPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = '成员',
    this.required = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: const Text('请先在"成员"页面添加一位成员'),
          );
        }
        final items = members
            .map(
              (m) => DropdownMenuItem<String>(
                value: m.id,
                child: Text(m.name),
              ),
            )
            .toList();
        return DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: items,
          onChanged: onChanged,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? '请选择成员' : null
              : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('成员加载失败: $e'),
    );
  }
}
