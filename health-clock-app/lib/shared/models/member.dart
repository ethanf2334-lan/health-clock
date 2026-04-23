import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
class Member with _$Member {
  const factory Member({
    required String id,
    required String userId,
    required String name,
    String? relation,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? allergies,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@freezed
class MemberCreate with _$MemberCreate {
  const factory MemberCreate({
    required String name,
    String? relation,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? allergies,
    String? notes,
  }) = _MemberCreate;

  factory MemberCreate.fromJson(Map<String, dynamic> json) =>
      _$MemberCreateFromJson(json);
}
