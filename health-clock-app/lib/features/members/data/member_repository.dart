import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
import '../../../shared/models/member.dart';

part 'member_repository.g.dart';

@riverpod
MemberRepository memberRepository(MemberRepositoryRef ref) {
  return MemberRepository(ref.watch(dioProvider));
}

/// 后端返回 snake_case，Dart 模型是 camelCase，在这里做一次统一转换。
Map<String, dynamic> _normalizeMember(Map<String, dynamic> json) {
  return {
    'id': json['id'],
    'userId': json['user_id'] ?? json['userId'],
    'name': json['name'],
    'relation': json['relation'],
    'gender': json['gender'],
    'birthDate': json['birth_date'] ?? json['birthDate'],
    'heightCm': json['height_cm'] ?? json['heightCm'],
    'weightKg': json['weight_kg'] ?? json['weightKg'],
    'bloodType': json['blood_type'] ?? json['bloodType'],
    'chronicConditions': json['chronic_conditions'] ?? json['chronicConditions'],
    'allergies': json['allergies'],
    'notes': json['notes'],
    'createdAt': json['created_at'] ?? json['createdAt'],
    'updatedAt': json['updated_at'] ?? json['updatedAt'],
  };
}

class MemberRepository {
  final Dio _dio;

  MemberRepository(this._dio);

  Future<List<Member>> getMembers() async {
    final response = await _dio.get('/members');
    final data = response.data['data'] as List;
    return data
        .map((json) => Member.fromJson(_normalizeMember(json as Map<String, dynamic>)))
        .toList();
  }

  Future<Member> getMember(String id) async {
    final response = await _dio.get('/members/$id');
    return Member.fromJson(_normalizeMember(response.data['data'] as Map<String, dynamic>));
  }

  Future<Member> createMember(MemberCreate member) async {
    final response = await _dio.post(
      '/members',
      data: member.toJson(),
    );
    return Member.fromJson(_normalizeMember(response.data['data'] as Map<String, dynamic>));
  }

  Future<Member> updateMember(String id, Map<String, dynamic> updates) async {
    final response = await _dio.put(
      '/members/$id',
      data: updates,
    );
    return Member.fromJson(_normalizeMember(response.data['data'] as Map<String, dynamic>));
  }

  Future<void> deleteMember(String id) async {
    await _dio.delete('/members/$id');
  }
}
