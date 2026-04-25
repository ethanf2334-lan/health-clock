import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/member.dart';
import 'member_provider.dart';

/// 当前选中的成员 ID。null 仅在还没有成员时使用。
final currentMemberIdProvider = StateProvider<String?>((ref) => null);

/// 自动确保有成员时默认选中一位。
///
/// 用户手动切换后会保留选择；如果当前成员被删除，则切到剩余第一位。
final ensureCurrentMemberProvider = Provider<void>((ref) {
  final membersAsync = ref.watch(memberListProvider);
  final currentId = ref.watch(currentMemberIdProvider);

  membersAsync.whenData((members) {
    if (members.isEmpty) {
      if (currentId != null) {
        Future.microtask(() {
          ref.read(currentMemberIdProvider.notifier).state = null;
        });
      }
      return;
    }

    final exists = members.any((member) => member.id == currentId);
    if (currentId == null || !exists) {
      Future.microtask(() {
        ref.read(currentMemberIdProvider.notifier).state = members.first.id;
      });
    }
  });
});

/// 当前选中的成员对象（派生自列表与 currentMemberId）。
final currentMemberProvider = Provider<Member?>((ref) {
  ref.watch(ensureCurrentMemberProvider);
  final id = ref.watch(currentMemberIdProvider);
  if (id == null) return null;
  final listAsync = ref.watch(memberListProvider);
  return listAsync.maybeWhen(
    data: (list) {
      for (final m in list) {
        if (m.id == id) return m;
      }
      return null;
    },
    orElse: () => null,
  );
});
