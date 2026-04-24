import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/member.dart';
import 'member_provider.dart';

/// 当前选中的成员 ID。null 表示"全部成员"。
final currentMemberIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的成员对象（派生自列表与 currentMemberId）。
final currentMemberProvider = Provider<Member?>((ref) {
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
