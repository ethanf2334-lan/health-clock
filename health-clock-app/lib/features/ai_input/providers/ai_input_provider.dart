import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';

part 'ai_input_provider.g.dart';

@riverpod
class AIParseResult extends _$AIParseResult {
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }

  Future<Map<String, dynamic>> parseText(
    String text, {
    String? memberId,
    String? memberName,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/ai/parse-text',
      data: {
        'text': text,
        if (memberId != null) 'member_id': memberId,
        if (memberName != null) 'member_name': memberName,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
