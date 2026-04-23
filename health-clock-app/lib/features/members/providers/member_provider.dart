import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/member.dart';
import '../data/member_repository.dart';

part 'member_provider.g.dart';

@riverpod
class MemberList extends _$MemberList {
  @override
  Future<List<Member>> build() async {
    return ref.watch(memberRepositoryProvider).getMembers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(memberRepositoryProvider).getMembers();
    });
  }

  Future<void> addMember(MemberCreate member) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(memberRepositoryProvider).createMember(member);
      return ref.read(memberRepositoryProvider).getMembers();
    });
  }

  Future<void> deleteMember(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(memberRepositoryProvider).deleteMember(id);
      return ref.read(memberRepositoryProvider).getMembers();
    });
  }
}
