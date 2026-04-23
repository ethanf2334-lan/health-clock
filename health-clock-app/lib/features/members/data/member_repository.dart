import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/models/member.dart';

part 'member_repository.g.dart';

@riverpod
MemberRepository memberRepository(MemberRepositoryRef ref) {
  return MemberRepository(ref.watch(dioProvider));
}

class MemberRepository {
  final Dio _dio;

  MemberRepository(this._dio);

  Future<List<Member>> getMembers() async {
    final response = await _dio.get('/members');
    final data = response.data['data'] as List;
    return data.map((json) => Member.fromJson(json)).toList();
  }

  Future<Member> getMember(String id) async {
    final response = await _dio.get('/members/$id');
    return Member.fromJson(response.data['data']);
  }

  Future<Member> createMember(MemberCreate member) async {
    final response = await _dio.post(
      '/members',
      data: member.toJson(),
    );
    return Member.fromJson(response.data['data']);
  }

  Future<Member> updateMember(String id, Map<String, dynamic> updates) async {
    final response = await _dio.put(
      '/members/$id',
      data: updates,
    );
    return Member.fromJson(response.data['data']);
  }

  Future<void> deleteMember(String id) async {
    await _dio.delete('/members/$id');
  }
}
